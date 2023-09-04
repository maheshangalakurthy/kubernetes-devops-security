#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:0.45.0 -q image --severity HIGH --exit-code 0 --light $dockerImageName
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy:0.45.0 -q image --severity CRITICAL --exit-code 1 --light $dockerImageName

exit_code=$?
echo "Exit Code : $exit_code"

if [[ "${exit_code}" == 1]]; then
  echo "Image Scanning failed. Vulnerabilties found"
  exit 1;
else
  echo "Images scanning passed. No vulnerabilities found"
fi
