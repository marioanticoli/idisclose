#!/bin/sh 

TAG=$(curl -s "https://hub.docker.com/v2/repositories/marioanticoli/idisclose/tags/"  | jq '.results[].name' | head -n 1 | tr -d '"')
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
    --help)
      echo -e "--skip-context-selection\tSkip the context selection (use in scripts)"
      echo -e "--skip-microk8s\t\t\tDon't use microk8s' kubectl"
      exit 0
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

kubectl apply -f prod-secret.yaml 
kubectl apply -f db-persistent-volume.yaml
kubectl apply -f db-persistent-volume-claim.yaml
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml
sed "17s/$/:$TAG/" migration-job.yaml | kubectl apply -f -
sed "17s/$/:$TAG/" web-deployment.yaml | kubectl apply -f -
kubectl apply -f web-service.yaml

kubectl get all

