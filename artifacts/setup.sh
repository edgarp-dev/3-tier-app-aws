#!/usr/bin/env bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--env) ENV="$2"; shift ;;
    esac
    shift
done

if [[ $ENV != 'dev' && $ENV != 'prod' ]]; then
        echo "invalid env, valid envs are dev and prod"
        exit 1
fi

ARTIFACTS_STACK_NAME="$ENV-three-tier-app-templates-bucket"

aws cloudformation deploy --stack-name $ARTIFACTS_STACK_NAME --template-file artifact-bucket.yaml
