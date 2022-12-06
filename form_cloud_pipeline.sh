#!/bin/bash

GIT_BRANCH='main'
ENV='dev'
DEPLOY_TO_PROD=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--env) ENV="$2"; shift ;;
        -c|--current-branch) GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD);
    esac
    shift
done

if [[ $ENV != 'dev' && $ENV != 'prod' ]]; then
        echo "$ENV is an invalid env, valid envs are dev and prod"
        exit 1
fi

if [[ $ENV == 'prod' ]]; then
        read -p "Are you sure you want to deploy to PROD env?(y/N)": USER_INPUT
        if [[ $USER_INPUT = 'y' ]]; then
                DEPLOY_TO_PROD=true
        fi
fi

if [[ $DEPLOY_TO_PROD = true && $GIT_BRANCH != 'main' ]]; then
        echo "You CAN'T deploy to prod using a different branch from main"
        exit 1
fi

CODEPIPELINE_STACK_NAME="$ENV-three-tier-app-pipeline"
STACK_INFO=$(aws cloudformation describe-stacks --stack-name $CODEPIPELINE_STACK_NAME)

STACK_ID=$(echo $STACK_INFO | jq -r '.Stacks[0].StackId')
CONFIG_ENV=$(jq .[0].ParameterValue ./config/$ENV.json)
CF_TEMPLATES_BUCKET=$(jq .[1].ParameterValue ./config/$ENV.json)

if [[ -n $STACK_ID ]]; then
        echo "Stacks exists"
        echo "Updating stack $CODEPIPELINE_STACK_NAME"

        aws cloudformation update-stack \
                --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
                --stack-name $CODEPIPELINE_STACK_NAME \
                --parameters ParameterKey=GithubBranch,ParameterValue=$GIT_BRANCH ParameterKey=Env,ParameterValue=$CONFIG_ENV ParameterKey=CfTemplatesBucket,ParameterValue=$CF_TEMPLATES_BUCKET \
                --template-body file://pipeline.yaml \
        
else
        echo "Stack does not exists"
        echo "Creating stack $CODEPIPELINE_STACK_NAME"

        aws cloudformation create-stack \
                --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
                --stack-name $CODEPIPELINE_STACK_NAME \
                --parameters ParameterKey=GithubBranch,ParameterValue=$GIT_BRANCH ParameterKey=Env,ParameterValue=$CONFIG_ENV ParameterKey=CfTemplatesBucket,ParameterValue=$CF_TEMPLATES_BUCKET \
                --template-body file://pipeline.yaml \

fi
