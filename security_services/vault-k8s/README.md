Vault is one of the most advanced security management tools provided by HashiCorp. This 
project contains files that can be used to deploy vault in a k8s cluster and it also put
unseal keys and vault root token in a predefined S3 bucket. In this project, only AWS 
cloud platform is used. However, by doing simple modification it can also
be used for other cloud platforms as well. 

Deploying a secure vault cluster in k8s with auto unsealing feature is a bit tricky job. The following section describes
AWS setup and Kubernetes deployment process in step by step.  

Steps by step:
===============

AWS setup 
---------

1. Create a DynamoDB table with Primary partition key **"Path"** and Primary sort key	**"Key"** that will be used by vault 
   as storage backend. Enable point-in-time recovery for DynamoDB. Change "Capacity" (read and write unit) of DynamoDB 
   table to adjust with vault [configuration](04-statefulset.yaml#L79-L80). Update **"VAULT_DYNAMODB_TABLE_NAME"** value 
   in [01-configmap.yaml](01-configmap.yaml#L8)
   
   
2. Create a S3 bucket where vault unseal keys and root token will be stored. 

3. Create and IAM role for vault. After that, create a KMS key for vault auto unsealing and allow only vault IAM role 
   to access the KMS key. 
   
4. Create an IAM policy for vault as below and attach this policy to the vault IAM role. Before creating the policy update
   the resource arns in the following policy document. 


    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "dynamodb:DescribeLimits",
                    "dynamodb:DescribeTimeToLive",
                    "dynamodb:ListTagsOfResource",
                    "dynamodb:ListTables",
                    "dynamodb:BatchGetItem",
                    "dynamodb:BatchWriteItem",
                    "dynamodb:CreateTable",
                    "dynamodb:DeleteItem",
                    "dynamodb:GetItem",
                    "dynamodb:GetRecords",
                    "dynamodb:PutItem",
                    "dynamodb:Query",
                    "dynamodb:UpdateItem",
                    "dynamodb:Scan",
                    "dynamodb:DescribeTable"
                ],
                "Effect": "Allow",
                "Resource": [
                    "arn:aws:dynamodb:eu-west-1:AWS_ACC_ID:table/DYNAMO_TABLE_NAME"
                ]
            },
            {
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": [
                    "arn:aws:s3:::S3_BUCKET_NAME",
                    "arn:aws:s3:::S3_BUCKET_NAME/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "kms:Encrypt",
                    "kms:Decrypt",
                    "kms:DescribeKey"
                ],
                "Resource": [
                    "arn:aws:kms:eu-west-1:AWS_ACC_ID:key/KMS_KEY_ID"
                ]
            }
        ]
    }
    ```

5. Create a VPC Endpint for your AWS VPC according to [this doc](https://docs.aws.amazon.com/kms/latest/developerguide/kms-vpc-endpoint.html)
   Make sure that the subnets configured in this VPC endpoint are the subnets where vault pods will be deployed. Otherwise,
   vault pods will not be able to access this VPC endpoint and auto unsealing will not work. Also make sure that the security
   group for this VPC endpoint allows inbound port 443. 
   
6. All the variables value in configmap **[vault-config](01-configmap.yaml#L7-L12)** should be replaced by proper values of the resources created in
   the above steps

Kubernetes deployment 
----------------------

1. First, we have to create TLS certificate for vault endpoint. The first file 
**"00-certificate.yaml"** creates a secret named **vault-tls** in the cluster which contains
necessary certificates and keys for vault. If you have [cert-manger](https://github.com/jetstack/cert-manager) 
available in your cluster then you have to create a letsencrypt [ClusterIssuer](https://docs.cert-manager.io/en/latest/reference/clusterissuers.html)
for your Route53 hosted zone. Once the **ClusterIssuer** is ready you can create the
final secret **vault-tls** by replacing the value of ${VAULT_ENDPOINT} in **"00-certificate.yaml"**
and then apply it 

   ```kubectl apply -f 00-certificate.yaml```

    If cert-manager is not available in your cluster then you can manually generate TLS certificate
for vault. For example: Let's consider you already have **ca.crt**, **vault.crt** and **vault.key** files ready. Now, 
put **ca.crt** and **vault.crt** in a single file 

    `cat ca.crt > vault-cert.crt && cat vault.crt >> vault-cert.crt`

    and create a kubernetes secret using the following command 

    `kubectl -n vault create secret tls vault-tls --key vault.key --cert vault-cert.crt`

2. There are two configmaps in **"01-configmap.yaml"** file. The first one (**vault-config**) 
contains information about the vault backend. This values will be passed as environment variables 
in the vault pods. Here you have to update the values of the variables with your config values. 
The second one **"vault-token-manager"** contains a simple script. After vault is initialized, this 
scripts unseals vault and put the unseal keys and root token in a pre-defined S3 bucket. The script is 
very simple and can be easily modified for other cloud platforms. 

    After updating the values in the first configmap run

    ```kubectl apply -f 01-configmap.yaml```
    
3. **02-sa-clusterRoleBinding.yaml** creates a ServiceAccount named **vault** and bind proper authorization with 
the ServiceAccount. 

    ```kubectl apply -f 02-sa-clusterRoleBinding.yaml```

4. **03-service.yaml** creates a LoadBalancer type service for vault. All the annotations in this 
file mainly used by [external-dns](https://github.com/kubernetes-incubator/external-dns) to create records 
in route53 for vault. If external-dns is not avilable in your cluster, a record can be created in route53 
that points the Loadbalancer for vault service.

    As vault is a secured service, it would be a good idea to keep it available from specific networks. This file 
    considers that you want to reach vault service privately from private network **10.0.0.0/8**. Make sure you update
    the value for **loadBalancerSourceRanges** in this file according to your requirement. 
    
    ```kubectl apply -f 03-service.yaml```
    
    Before creating the vault StatefulSet, make sure that the vault endpoint is already resolvable 
    
    ```nslookup $YOUR_VAULT_ENDPOINT```
    
5. Now we are ready to deploy a vault cluster. **04-statefulset.yaml** deploys a StatefulSet with 3 replicas i.e. 3 node
vault cluster. [This](https://github.com/Sakib37/DevOps/blob/master/security_services/vault-k8s/04-statefulset.yaml#L19)
annotation is used by [kube2iam]() which ensures that vault pod can get AWS token to make relevant requests to AWS api. 
However, if you are not using **kube2iam**, make sure that vault pod can access necessary cloud resources(Ex- DynamoDB table,
S3bucket, KMS keys etc.). The [affinity](https://github.com/Sakib37/DevOps/blob/master/security_services/vault-k8s/04-statefulset.yaml#L22-L38)
configuration ensures that vault pods are scheduled in different k8s node and different availability zones. You can comment
or modify the **podAntiAffinity** based on your requirement. Vault server configuration is represented by [this](https://github.com/Sakib37/DevOps/blob/master/security_services/vault-k8s/04-statefulset.yaml#L62-L86)
section. This vault server configuration uses DynamoDB as vault backend. If you want to use different backend for vault, 
update this vault configuration section based on your backend. 

    There are two containers ([token-manager](https://github.com/Sakib37/DevOps/blob/master/security_services/vault-k8s/04-statefulset.yaml#L92-L117)
    and [vault](https://github.com/Sakib37/DevOps/blob/master/security_services/vault-k8s/04-statefulset.yaml#L118-L188))
    in a pod. The **vault** container runs a vault server. The **${VAULT_ENDPOINT}** variable should be replaced by your
    vault endpoint name in the [configuration](https://github.com/Sakib37/DevOps/blob/master/security_services/vault-k8s/04-statefulset.yaml#L126).
    The **token-manager** container is simply a container with AWS CLI. After vault operator is initialized, the auto unsealing
    script runs inside this container and copy unsealing keys and root token to the S3 bucket. 
