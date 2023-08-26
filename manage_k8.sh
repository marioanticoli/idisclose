#!/bin/sh 

confirm_and_run() {
  local command_name="$1"

  read -p "Do you want to run '$command_name'? (y/n): " choice
  case "$choice" in
    y|Y )
      echo "Running '$command_name'..."
      ;;
    *)
      echo "Exiting."
      exit 0
      ;;
  esac
}

IMAGE_LINE=17

SKIP_CONTEXT_SELECTION=false
#USE_MICROK8S=true
COMMAND=
TAG=$(curl -s "https://hub.docker.com/v2/repositories/marioanticoli/idisclose/tags/"  | jq '.results[].name' | head -n 1 | tr -d '"')
IMAGE=$(sed -n "${IMAGE_LINE}s/.*image: \([^[:space:]]*\).*/\1/p" k8s/web-deployment.yaml)

#while getopts ":adrb:cme:i:t:h" opt; do
while getopts ":adrb:ci:t:h" opt; do
  case $opt in
    a)
      COMMAND=apply_all
      ;; 
    d)
      COMMAND=delete_all
      ;;
    r)
      COMMAND=rollout
      ;;
    b)
      DEPLOYMENT=$OPTARG 
      ;;
    c) 
      SKIP_CONTEXT_SELECTION=true 
      ;; 
    #m) 
      #USE_MICROK8S=false 
      #;;
    #e)
      #COMMAND=$OPTARG 
      #;;
    i)
      IMAGE=$OPTARG
      ;;
    t)
      TAG=$OPTARG
      ;;
    h)
      echo -e "-a\tDeploy everything"
      echo -e "-d\tDelete everything"
      echo -e "-r\tRollout (requires to set -b deployment)"
      echo -e "-b\tThe deployment name (only for rollout)"
      echo -e "-c\tSkip the context selection (use in scripts)"
      #echo -e "-m\tDon't use microk8s' kubectl"
      #echo -e "-e\tA kubectl command to execute"
      echo -e "-i\tAn image to pull instead of the default one"
      echo -e "-t\tA tag instead of the most recent published (not \"latest\")"
      echo -e "-h\tThis help"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      ;;
  esac
done

if [ -z "$COMMAND" ]; then
  echo "Error: COMMAND is not set. Please specify a command or run the script with -h for help."
  exit 1
else
  confirm_and_run "$COMMAND"
fi

#if $USE_MICROK8S; then
  #alias kubectl='microk8s kubectl'
#fi

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

if [ "$COMMAND" = "apply_all" ]; then
  kubectl apply -f k8s/prod-secret.yaml 
  kubectl apply -f k8s/db-persistent-volume.yaml
  kubectl apply -f k8s/db-persistent-volume-claim.yaml
  kubectl apply -f k8s/db-deployment.yaml
  kubectl apply -f k8s/db-service.yaml
  echo "Using $IMAGE:$TAG"
  sed -e "${IMAGE_LINE}s|image: .*|image: $IMAGE|" -e "${IMAGE_LINE}s|$|:$TAG|" k8s/migration-job.yaml | kubectl apply -f -
  sed -e "${IMAGE_LINE}s|image: .*|image: $IMAGE|" -e "${IMAGE_LINE}s|$|:$TAG|" k8s/web-deployment.yaml | kubectl apply -f -
  kubectl apply -f k8s/web-service.yaml
  kubectl apply -f k8s/web-service-headless.yaml
  kubectl apply -f k8s/service-account.yaml
  kubectl apply -f k8s/roles.yaml

  kubectl get all
elif [ "$COMMAND" = "delete_all" ]; then
  kubectl delete serviceaccount idisclose-service-account
  kubectl delete rolebinding pod-list-role-binding
  kubectl delete role pod-list-role
  kubectl delete services idisclose-web-headless
  kubectl delete services idisclose-web-service
  kubectl delete services idisclose-db-service 
  kubectl delete deployments idisclose-web
  kubectl delete deployments idisclose-db
  kubectl delete persistentvolumeclaims idisclose-postgres-data-persisent-volume-claim
  kubectl delete persistentvolume idisclose-postgres-data-persisent-volume 
  kubectl delete secret prod-secret
  kubectl delete jobs idisclose-migrations

  kubectl get all
elif [ "$COMMAND" = "rollout" ]; then
  if [ -z "$DEPLOYMENT" ]; then
    echo "Error: DEPLOYMENT is not set. Please specify a deployment."
    exit 1
  else
    kubectl rollout restart deployment $DEPLOYMENT
  fi
#else 
  #kubectl $COMMAND
fi


