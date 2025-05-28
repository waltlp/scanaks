#!/usr/bin/env sh
#################
#This script will gather logs from an AKS cluster. The goal is to collect those logs for troubleshooting purposes.
#This script is work in progress. It is developed in best effort. Lots of improvements are expected.
#
#Author: Walter Lopez <walter.lopez[at]microsoft.com>
#
#TO DO
# Validate that the required utilities are installed and suggested where to find them if not.
# Validate that the user is logged in to Azure.
# Validate that the user has chosen the right subscription.
# Validate that the user is merged to an AKS cluster.
# Add a myriad of exceptions.
# Other tasks not documented here yet.

#Variables
##########
# Ask for the Service Request number
read -p "Enter your SERVICE REQUEST: " SERVICE_REQUEST

# Prompt the user to enter the RESOURCE_GROUP
read -p "Enter the AKS CLUSTER RESOURCE GROUP: " RESOURCE_GROUP

# Prompt the user to enter the CLUSTER_NAME
read -p "Enter the AKS CLUSTER NAME: " CLUSTER_NAME

NOW=$(date +%F_%H-%M-%S_%z)

RANDOMSTRING=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]' | fold -w ${1:-4} | head -n 1)

#A place for the logs
#####################

# Create a directory to hold the logs
mkdir ~/LOGS_${SERVICE_REQUEST}_${RANDOMSTRING}

# Move to the directory that will hold the logs
cd ~/LOGS_${SERVICE_REQUEST}_${RANDOMSTRING}

#General information
####################

#Determine the version of the Azure CLI
az version > azure-cli-version.txt

#Determine the version of the installed "kubectl" utility.
kubectl version > kubectl-version.txt

#Gather basic information about the AKS cluster.
kubectl cluster-info > k_cluster-info.txt

#Export details about the AKS cluster.
az aks show -g $RESOURCE_GROUP -n $CLUSTER_NAME > az-aks-show_$NOW.json

#Check out the existing worker nodes of the AKS cluster.
kubectl get nodes -o wide > k_nodes_$NOW.txt

#Check out the existing pods of the AKS cluster.
kubectl get pods -A -o wide > k_pods_$NOW.txt

#Create a dump of the events in the cluster.
kubectl get events > k_get-events_$NOW.txt

#Check the CPU/memory of the nodes.
kubectl top nodes > k_top_nodes_$NOW.txt

#Check the CPU/memory used by the containers.
kubectl top pods -A > k_top_pods_$NOW.txt

#Check for all the Ingresses
kubectl get ingress -A > k_ingress_$NOW.txt

#Check for all the existing kubernetes Services
kubectl get svc -A > k_services_$NOW.txt

#Check for endpoints
kubectl get endpoints -A > k_endpoints_$NOW.txt

# Post script execution tasks
#############################

#Move to the parent directory
cd ~

#TAR and compress the directory that holds the logs
tar -czf LOGS_${SERVICE_REQUEST}_${RANDOMSTRING}.tar.gz LOGS_${SERVICE_REQUEST}_${RANDOMSTRING}

#Announcements
##############
echo "The script has ended its task. Please upload the file ${HOME}/LOGS_${SERVICE_REQUEST}_${RANDOMSTRING}.tar.gz to the file vault."
