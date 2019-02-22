Vault is one of the most advanced security management tools provided by HashiCorp. This 
project contains files that can be used to deploy vault in a k8s cluster and it also put
unseal keys and vault root token in a predefined S3 bucket. In this project, only AWS 
cloud platform is used. However, by doing simple modification it can also
be used for other cloud platforms as well. 

Deploying a secure vault cluster in k8s with auto unsealing feature is a bit tricky job. 
However, after updating some variables in the yaml files in this repository, vault can be deployed simply by running

```kubectl apply -f vault-k8s/``` 

Steps by step:
===============

###AWS setup 

2. Create a dynamodb table that will be used by vault as storage backend. Enable point-in-time 
   recovery for dynamodb. Change "Capacity" of Dynamodb table to adjust with vault configuration. 
   Update "VAULT_DYNAMODB_TABLE_NAME" value in 01-configmap.yaml
   
3. Create a KMS key for vault auto unsealing and allow only vault IAM role to access the key.
   Create an IAM policy for vault as below. Update Dynamo table name, S3 bucket name and KMS key id


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



###Kubernetes deployment 

1. First, we have to create TLS certificate for vault endpoint. The first file 
*"00-certificate.yaml"* creates a secret named *vault-tls* in the cluster which contains
necessary certificates and keys for vault. If you have [cert-manger](https://github.com/jetstack/cert-manager) 
available in your cluster then you have to create a letsencrypt [ClusterIssuer](https://docs.cert-manager.io/en/latest/reference/clusterissuers.html)
for your Route53 hosted zone. Once the *ClusterIssuer* is ready you can create the
final secret *vault-tls* by replacing the value of ${VAULT_ENDPOINT} in *"00-certificate.yaml"*
and then apply it 

   ```kubectl apply -f 00-certificate.yaml```

    If cert-manager is not available in your cluster then you can manually generate TLS certificate
for vault. For example: Let's consider you already have *ca.crt*, *vault.crt* and *vault.key* files ready. Now, 
put *ca.crt* and *vault.crt* in a single file 

    `cat ca.crt > vault-cert.crt && cat vault.crt >> vault-cert.crt`

    and create a kubernetes secret using the following command 

    `kubectl -n vault create secret tls vault-tls --key vault.key --cert vault-cert.crt`

2. There are two configmaps in *"01-configmap.yaml"* file. The first one (*vault-config*) 
contains information about the vault backend. This values will be passed as environment variables 
in the vault pods. Here you have to update the values of the variables with your config values. 
The second one *"vault-token-manager"* contains a simple script. After vault is initialized, this 
scripts unseals vault and put the unseal keys and root token in a pre-defined S3 bucket. The script is 
very simple and can be easily modified for other cloud platforms. 

    After updating the values in the first configmap run

    ```kubectl apply -f 01-configmap.yaml```
    
3. *02-sa-clusterRoleBinding.yaml* creates a ServiceAccount named *vault* and bind proper authorization with 
the ServiceAccount. 

    ```kubectl apply -f 02-sa-clusterRoleBinding.yaml```

4. *03-service.yaml* creates a LoadBalancer type service for vault. All the annotations in this 
file mainly used by [external-dns](https://github.com/kubernetes-incubator/external-dns) to create records 
in route53 for vault. If external-dns is not avilable in your cluster, a record can be created in route53 
that points the Loadbalancer for vault service.

    As vault is a secured service, it would be a good idea to keep it available from specific networks. This file 
    considers that you want to reach vault service privately from private network *10.0.0.0/8*. Make sure you update
    the value for *loadBalancerSourceRanges* in this file according to your requirement. 
    
    ```kubectl apply -f 03-service.yaml```
