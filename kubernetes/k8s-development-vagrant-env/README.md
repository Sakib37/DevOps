KUPA: HA Kubernetes Platform Simulation Using Vagrant
========================================================

A vagrant-based highly available Kubernetes Development Environment 

Components, Tools and Versions
------------------------------

|component  | version|
| --------- |  -------- |
|ubuntu | 16.04.3 |
|kubernetes | 1.10.0 |
|docker | 1.13.1 |
|etcd | 3.2.18 |
|rook (ceph storage) | 0.7.0 |
|cni | 0.6.0 |
|cri-containerd | 1.0.0-alpha.0 |
|runc | 1.0.0-rc4 |
|weave net | 2.0.5 |
|istio | 0.7.0|
|cfssl | 1.2.0 |


Required arguments
------------------------

To run the CLI, kupa, the following arguments are needed

```bash
	--help              Show this message
	--hosts             Displays the hosts information of a machine in the Multi-VM environment
	--machine           Optional parameter. Specifies the name of the node on which operation should be perfomed. 
	                    If sepcified, this optional parameter needs to come first in the list of paramters.
	--start             Starts the Kubernetes Platform Environment Machines
	--restart           Restarts the Kubernetes Platform Environment Machines
	--shutdown          Shuts down the Kubernetes Platform Environment Machines
	--terminate         Terminates the Kubernetes Platform Environment Machines
	--status            Displays the status of the underlying machines in the Kubernetes Platform Environment
	--ssh               Executes an ssh session to underlying machines in the Kubernetes Platform Environment
```
	
	
Usage
-------------------

```bash
	kupa [--help] [--hosts] [--testplan] [ [--machine] [ --start | --restart | --shutdown | --terminate | --status | --sssh ] ]
```


###### Print help

```bash
	kupa --help
```

###### Print IP information for all vagrant instances in the Kubernetes Platform Environment

```bash
	kupa --hosts
```

###### Start the Kubernetes Platform Environment

```bash
	kupa --start
```

###### Start a machine (foo) in the Kubernetes Platform Environment

```bash
	kupa --machine=foo --start
```

###### Restart the Kubernetes Platform Environment

```bash
	kupa --restart
```

###### Restart a machine (foo) in the Kubernetes Platform Environment

```bash
	kupa --machine=foo --restart
```

###### Shutdown the Kubernetes Platform Environment

```bash
	kupa --shutdown
```

###### Shutdown a machine (foo) in the Kubernetes Platform Environment

```bash
	kupa --machine=foo --shutdown
```

###### Terminate the Kubernetes Platform Environment

```bash
	kupa --terminate
```

###### Terminate a machine (foo) in the Kubernetes Platform Environment

```bash
	kupa --machine=foo --terminate
```

###### Display the status of all machines in the Kubernetes Platform Environment

```bash
	kupa --status
```

###### Display the status of a machine (foo) in the Kubernetes Platform Environment

```bash
	kupa --machine=foo --status
```

###### SSH into a machine (foo) in the Kubernetes Platform Environment

```bash
	kupa --machine=foo --ssh
```

## Configure the Kubernetes CLI

```bash
    
    # configure the kubeconfig credentials for the CLI
    export KUBECONFIG=conf/kubeconfig/admin.kubeconfig
    
    # configure the editor to use if you wish to use "kubectl edit" during dev/tests
    export KUBE_EDITOR=nano
    
    # as an alternative to the 2 commands above, you could instead run
    source kubectl-config
    
    # configure kubernetes CLI autocompletion
    sudo bash -c 'kubectl completion bash > /etc/bash_completion.d/kubectl'
    source /etc/bash_completion.d/kubectl
    
    # test that the CLI is able to speak with the kubernetes apiserver
    kubectl get pods --all-namespaces -o wide
```

## Access Kubernetes Dashboard

```bash
    kubectl proxy &
```
