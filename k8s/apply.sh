#!/bin/sh 

TAG=$(curl -s "https://hub.docker.com/v2/repositories/marioanticoli/idisclose/tags/"  | jq '.results[].name' | head -n 1 | tr -d '"')

kubectl apply -f prod-secret.yaml 
kubectl apply -f db-persistent-volume-claim.yaml
kubectl apply -f db-persistent-volume.yaml
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml 
sed "17s/$/:$TAG/" migration-job.yaml | kubectl apply -f -
sed "17s/$/:$TAG/" web-deployment.yaml | kubectl apply -f -
kubectl apply -f web-loadbalancer.yaml

kubectl get all
