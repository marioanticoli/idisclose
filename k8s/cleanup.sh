#!/bin/sh 

SKIP_CONTEXT_SELECTION=false
USE_MICROK8S=true

for arg in "$@"; do
  case $arg in
    --skip-context-selection)
      SKIP_CONTEXT_SELECTION=true
      ;;
     --skip-microk8s)
      USE_MICROK8S=false
      ;;
  esac
done

if $USE_MICROK8S; then
  alias kubectl='microk8s kubectl'
fi

if ! $SKIP_CONTEXT_SELECTION; then
  contexts=$(kubectl config get-contexts -o name)
  contexts_array=($contexts)

  echo "Kubernetes Contexts:"
  for i in "${!contexts_array[@]}"; do
    echo "$i. ${contexts_array[$i]}"
  done

  valid_input=false
  while [ "$valid_input" = false ]; do
    read -p "Choose a Kubernetes context by entering the corresponding number: " context_number
    if [[ "$context_number" =~ ^[0-9]+$ ]] && [ "$context_number" -ge 0 ] && [ "$context_number" -lt "${#contexts_array[@]}" ]; then
      valid_input=true
    fi
  done

  selected_context=${contexts_array[$context_number]}
  kubectl config use-context $selected_context
fi

kubectl delete services idisclose-web-service
kubectl delete services idisclose-db-service 
kubectl delete deployments idisclose-web
kubectl delete deployments idisclose-db
kubectl delete persistentvolumeclaims idisclose-postgres-data-persisent-volume-claim
kubectl delete persistentvolume idisclose-postgres-data-persisent-volume 
kubectl delete secret prod-secret
kubectl delete jobs idisclose-migrations

kubectl get all

