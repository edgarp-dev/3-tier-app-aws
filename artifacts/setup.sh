#!/usr/bin/env bash

ARTIFACTS_STACK_NAME="three-tier-app-artifacts"

aws cloudformation deploy --stack-name $ARTIFACTS_STACK_NAME --template-file artifact-bucket.yaml

STACK_DESCRIPTION=$(aws cloudformation describe-stacks --stack-name $ARTIFACTS_STACK_NAME)

ARTIFACTS_BUCKET_NAME=$(echo $STACK_DESCRIPTION | jq -r '.Stacks[0].Outputs[0].OutputValue')

cd ..

cd ./templates

aws s3 sync . s3://$ARTIFACTS_BUCKET_NAME
