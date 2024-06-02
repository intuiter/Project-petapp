#!/bin/bash

ECR_REPO=$1
IMAGE_TAG=$2
REGION=$3
SCAN_STATUS=1

// THIS SCRIPT IS RUNNING ON BUILD MACHINE. FOR THIS SCRIPT WE NEED DOCKER MAVEN AND AWS.   THAT IS THE REASON WE HAVE INSTALLED ALL OF THESE AS ROLES WITH ANSIBLE PREVIOUSLY.

# Check if scan is complete
// THIS WILL BE ON LOOP UNTIL THE SCANNING IS FINISHED
until [ "$SCAN_STATUS" -eq "0" ];
do  
  echo "aws ecr wait image-scan-complete --region $REGION --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG"
  SCAN_STATUS=$(aws ecr wait image-scan-complete --region $REGION --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG; echo $?)
  echo "Waiting for scan to complete"
  sleep 5
done

=====================================
// DESCRIBE THE IMAGE SCANNING FINDINGS
// BUT IT WRITTENS IN JSON FORMAT. FOR THAT WE ARE USING JQ TOOL TO FILTER THE PARTICULAR KEY

# Get the Scan results
echo "aws ecr describe-image-scan-findings --region $REGION --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG | jq '.imageScanFindings.findingSeverityCounts'"
SCAN_FINDINGS=$(aws ecr describe-image-scan-findings --region $REGION --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG | jq '.imageScanFindings.findingSeverityCounts')


// WE ARE DOING ALL THE CHECKS
CRITICAL=$(echo $SCAN_FINDINGS | jq '.CRITICAL')
HIGH=$(echo $SCAN_FINDINGS | jq '.HIGH')
MEDIUM=$(echo $SCAN_FINDINGS | jq '.MEDIUM')
LOW=$(echo $SCAN_FINDINGS | jq '.LOW')
INFORMATIONAL=$(echo $SCAN_FINDINGS | jq '.INFORMATIONAL')
UNDEFINED=$(echo $SCAN_FINDINGS | jq '.UNDEFINED')


// WE ARE CHECKING IF THERE IS ANY LINE WITH KEY 'ERROR' AND ALSO IF IT IS IN MORE THAN 1 LINE THEN CONSIDER THE DOCKERFILE HAS LINT ERROR AND CONSIDER THIS SCRIPT AS FAIL
echo "CHECK IF DOCKERFILE HAS LINT ERROR:"
LINTERR=$(grep error dockerlinter.log|wc -l)
if [ "$LINTERR" -gt "0"]; then
   echo "======================================"
   echo "** Dockerfile contains lint errors ***"
   echo "======================================"
   exit 1 
fi

//HERE, ONLY THE HIGH VULNERABILITY IS ABOVE 50, WE ARE CONSIDERING IT AS NOT A GOOD IMAGE.
echo "CHECK IF DOCKER_IMAGE HAS VULNERABILITIES:"
if [ $CRITICAL != null ] || [ $HIGH != null ]; then
 if [ "$HIGH" -gt "50" ]; then
   echo "============================================"
   echo "** Docker image contains vulnerabilities ***"
   echo "============================================"
   exit 1  
 fi
fi

echo "INFO: No Vulnerabilities found"