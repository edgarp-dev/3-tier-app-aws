#!/bin/bash

CODEPIPELINE_STACK_NAME="three-tier-app-pipeline"
CURRENT_BRANCH='main'

if [ -z ${1} ]
then
	echo "PIPELINE CREATION FAILED!"
        echo "Pass your Github OAuth token as the first argument"
	exit 1
fi

set -u

if [ $# -eq 2 ]; then
        if [ "$2" == "-c" ]; then
                echo "Current branch selected"
                CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
                echo "Current branch ----> $CURRENT_BRANCH"
        fi
fi

STACK_INFO=$(aws cloudformation describe-stacks --stack-name $CODEPIPELINE_STACK_NAME)

STACK_ID=$(echo $STACK_INFO | jq -r '.Stacks[0].StackId')

if [[ -n $STACK_ID ]]; then
        echo "Stacks exists"
        echo "Updating stack"

        aws cloudformation update-stack \
                --capabilities CAPABILITY_IAM \
                --stack-name $CODEPIPELINE_STACK_NAME \
                --parameters ParameterKey=GithubOAuthToken,ParameterValue=${1} \
                ParameterKey=GithubBranch,ParameterValue=$CURRENT_BRANCH \
                --template-body file://pipeline.yaml
        
else
        echo "Stack does not exists"
        echo "Creating stack"

        aws cloudformation create-stack \
                --capabilities CAPABILITY_IAM \
                --stack-name $CODEPIPELINE_STACK_NAME \
                --parameters ParameterKey=GithubOAuthToken,ParameterValue=${1} \
                ParameterKey=GithubBranch,ParameterValue=$CURRENT_BRANCH \
                --template-body file://pipeline.yaml
fi