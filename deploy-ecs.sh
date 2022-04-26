#!/bin/bash

#Script to get current task definition, and based on that add new ecr image address to old template and remove attributes that are not needed, then we send new task definition, get new revision number from output and update service
set -e
ECR_IMAGE="accountid.dkr.ecr.eu-central-1.amazonaws.com/projectname:${BRANCH_NAME}-${BUILD_NUMBER}"
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition taskdefination-${EnvironmentType} --region eu-central-1)
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$ECR_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.registeredAt) | del(.registeredBy) | del(.compatibilities)')
NEW_TASK_INFO=$(aws ecs register-task-definition --region eu-central-1 --cli-input-json "$NEW_TASK_DEFINTIION")
NEW_REVISION=$(echo $NEW_TASK_INFO | jq '.taskDefinition.revision')
aws ecs update-service --cluster clustername-${EnvironmentType} --service service-${EnvironmentType} --task-definition taskdefination-${EnvironmentType}:${NEW_REVISION}
echo "Service is deployed"
