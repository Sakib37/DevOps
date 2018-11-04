#!/bin/bash
# created by:   Mohammad Badruzzaman < shakib37@gmail.com >
# since:        17.01.2018
# description:  Script for setting up a development k8s cluster

source bootstrap/common/common.sh

# The usage text method
function usage() {
cat << EOF
usage: $0 options

OPTIONS:
--help              Show this message
--hosts             Displays the hosts information of a machine in the Kubernetes Platform Development Environment
--machine           Specifies the name of the node on which operation should be perfomed
--start             Starts the Kubernetes Platform Development Environment
--restart           Restarts the Kubernetes Platform Development Environment
--shutdown          Shuts down the Kubernetes Platform Development Environment
--terminate         Terminates the Kubernetes Platform Development Environment
--status            Displays the status of the underlying machines in the Kubernetes Platform Development Environment
--ssh               Executes an ssh session to underlying machines in the Kubernetes Platform Development Environment
EOF
}

# Display the list of hosts and their addresses within the Kubernetes Platform Development Environment

function show_hosts(){
	vagrant hosts list
}

# If the list of options (stored in the $@ variable) is empty then print the usage instructions

if [[ -z $@ ]]
then
	usage
	exit 1
fi

# Parse the list of option flags.

for option in "$@"; do
	case $option in
	    --help)
	    usage
	    exit 0
	    ;;
	    --hosts)
	    show_hosts
	    exit 0
	    ;;
	    --start)
	    START=true
	    ;;
	    --restart)
	    RESTART=true
	    ;;
	    --shutdown)
	    SHUTDOWN=true
	    ;;
	    --terminate)
	    TERMINATE=true
	    ;;
	    --status)
	    STATUS=true
	    ;;
	    --ssh)
	    SSH=true
	    ;;
	    --machine=*)
	    export MACHINE="${option#*=}"
	    ;;
	    *)
	    echo Incorrect option to $0: ${option#*=}
	    usage
	    exit 1
	    ;;
	esac
done


MAX_PROCS=$(nproc)

if [[ -n ${START} ]]
then
    # Print welcome message
    print_welcome

    echo "starting with the following config: "
    echo ""
    cat conf/config.json | jq .

    # Check (and create if necessary) that the Etcd Cluster discovery url exists in the conf/discovery file
    # use conf['masters']['count'] for the size as etcd should only run on the kubernetes servers (masters)
    if [ ! -f conf/etcd-discovery ]
    then
        echo "etcd cluster autodiscovery url doesn't exist! creating one now"

        ETCD_CLUSTER_SIZE=$(cat conf/config.json | jq .masters.count --raw-output)
        ETCD_DISCOVERY_URL=$(cat conf/config.json | jq .etcd_discovery_service --raw-output)

        curl -s ${ETCD_DISCOVERY_URL}${ETCD_CLUSTER_SIZE} > conf/etcd-discovery
    fi
    
    
    mkdir -p logs tls disks  temp_downloaded

    # start the vms in series
	vagrant up --no-provision $MACHINE | tee logs/boot.log

    # provisioning the first vm alone so that next vms can use the already downloaded binaries
    FIRST_VM="k8s-server-1"
    echo "provisioning ${FIRST_VM}"
    vagrant provision ${FIRST_VM} | tee -a logs/${FIRST_VM}-provision.log

    # provision all other vms in parallel
    for one in $(vagrant hosts list | awk  '!/k8s-server-1/ {print $2}')
    do
        echo "provisioning ${one}"
        vagrant provision ${one} | tee -a logs/${one}-provision.log &
    done

    wait
    
    echo "done provisioning all vms"
    
    
    export K8S_ENABLE_POD_SECURITY_POLICIES=$(cat conf/config.json | jq .enable_pod_security_policies --raw-output)
    export K8S_ENABLE_NETWORK_POLICIES=$(cat conf/config.json | jq .enable_network_policies --raw-output)
    export K8S_ENABLE_SERVICE_MESH=$(cat conf/config.json | jq .enable_service_mesh --raw-output)
    export K8S_ENABLE_ROOK_STORAGE=$(cat conf/config.json | jq .enable_rook_storage --raw-output)
    export K8S_ENABLE_SAMPLE_APPS=$(cat conf/config.json | jq .enable_sample_apps --raw-output)
    export K8S_WORKER_COUNT=$(cat conf/config.json | jq .workers.count --raw-output)

    
    echo "starting up kubernetes control plane"
    bin/startup-kubernetes-control-plane.sh

    if [ "${K8S_ENABLE_POD_SECURITY_POLICIES}" = true ]
    then
        echo "configure pod security policies"
        bin/configure-pod-policies.sh
    fi

    echo "configuring namespaces"
    bin/configure-namespaces.sh

    echo "configuring authorization"
    bin/configure-authorization.sh

    if [ "${K8S_WORKER_COUNT}" -gt "0" ]
    then
        echo "configuring networking"
        bin/configure-networking.sh

        echo "deploying kubernetes operators"
        #bin/configure-operators.sh

        echo "deploying monitoring infrastructure"
        bin/configure-monitoring.sh

        echo "deploying security infrastructure"
        bin/configure-security.sh

        if [ "${K8S_ENABLE_ROOK_STORAGE}" = true ]
        then
            echo "deploying storage infrastructure"
            bin/configure-storage.sh
        fi

        if [ "${K8S_ENABLE_SERVICE_MESH}" = true ]
        then
            echo "deploying service mesh infrastructure"
            bin/configure-service-mesh.sh
        fi

        #echo "deploying log collection infrastructure"
        #bin/configure-logging.sh

        if [ "${K8S_ENABLE_SAMPLE_APPS}" = true ]
        then
            echo "deploying sample applications"
            bin/configure-sample-apps.sh
        fi
    fi

	exit 0


elif [[ -n $RESTART ]]
then
    vagrant reload --provision $MACHINE
    exit 0
elif [[ -n $SHUTDOWN ]]
then
    vagrant suspend $MACHINE
    exit 0
elif [[ -n $TERMINATE ]]
then
    vagrant destroy -f $MACHINE
    #rm -rf tls/ca tls/etcd tls/kubernetes tls/portworx tls/ca.csr tls/ca.json
    rm -rf tls/*
    rm -rf conf/etcd-discovery
    rm -rf conf/data-encryption-config.yaml
    rm -rf conf/kubeconfig
    rm -rf disks/*
    rm -rf logs/* 
    rm -rf .vagrant
exit 0
elif [[ -n $STATUS ]]
then
    vagrant status $MACHINE
    exit 0
elif [[ -n $SSH ]]
then
    if [[ -n $MACHINE ]]
    then
    	vagrant ssh $MACHINE
    	exit 0
    else
    	echo "The --ssh option requires a target machine to be specified. Please specify a machine using --machine"
    	exit 1
    fi
fi
