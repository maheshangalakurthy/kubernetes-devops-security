#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm  -v $WORKSPACE:/root/.cache/ aquasec/trivy image --severity CRITICAL --exit-code 1 $dockerImageName
docker run --rm  -v $WORKSPACE:/root/.cache/ aquasec/trivy image --severity HIGH --exit-code 0 $dockerImageName

 exit_code=$?
 echo "Exit Code : $exit_code"

 if [[ "${exit_code}" == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No CRITICAL vulnerabilities found"
    fi;