#!/bin/sh 

SKIP_CONTEXT_SELECTION=false
USE_MICROK8S=true
COMMAND=

for arg in "$@"; do
  case $arg in
    --skip-context-selection)
      SKIP_CONTEXT_SELECTION=true
      ;;
    --skip-microk8s)
      USE_MICROK8S=false
      ;;
    --apply) 
      COMMAND=apply 
      ;;
    --clean)
      COMMAND=delete 
      ;;
    --help)
      echo -e "--apply | --clean\t\tSelect the action to execute"
      echo -e "--skip-context-selection\tSkip the context selection (use in scripts)"
      echo -e "--skip-microk8s\t\t\tDon't use microk8s' kubectl"
      exit 0
  esac
done

if [ -z "$COMMAND" ]; then
  echo "Error: COMMAND is not set. Please specify --apply or --clean."
  exit 1
fi

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

if [ "$COMMAND" = "apply" ]; then
  TAG=$(curl -s "https://hub.docker.com/v2/repositories/marioanticoli/idisclose/tags/"  | jq '.results[].name' | head -n 1 | tr -d '"')

  kubectl apply -f k8s/prod-secret.yaml 
  kubectl apply -f k8s/db-persistent-volume.yaml
  kubectl apply -f k8s/db-persistent-volume-claim.yaml
  kubectl apply -f k8s/db-deployment.yaml
  kubectl apply -f k8s/db-service.yaml
  sed "17s/$/:$TAG/" k8s/migration-job.yaml | kubectl apply -f -
  sed "17s/$/:$TAG/" k8s/web-deployment.yaml | kubectl apply -f -
  kubectl apply -f k8s/web-service.yaml

elif [ "$COMMAND" = "delete" ]; then
  kubectl delete services idisclose-web-service
  kubectl delete services idisclose-db-service 
  kubectl delete deployments idisclose-web
  kubectl delete deployments idisclose-db
  kubectl delete persistentvolumeclaims idisclose-postgres-data-persisent-volume-claim
  kubectl delete persistentvolume idisclose-postgres-data-persisent-volume 
  kubectl delete secret prod-secret
  kubectl delete jobs idisclose-migrations
fi

kubectl get all

