#!/bin/bash

#integration-test.sh

sleep 5s

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

echo $PORT
echo $applicationURL:$PORT/$applicationURI
curl -s -o /dev/null -w "%{http_code}" devsecops-proj.eastus.cloudapp.azure.com:30638/increment/99
curl -s devsecops-proj.eastus.cloudapp.azure.com:30638/increment/99
# if [[ ! -z "$PORT" ]];
# then

#     response=$(curl -s $applicationURL:$PORT/$applicationURI)
#     echo $response
#     http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)
    
#     if [[ "$response" == 100 ]];
#         then
#             echo "Increment Test Passed"
#         else
#             echo "Increment Test Failed"
#             exit 1;
#     fi;

#     if [[ "$http_code" == 200 ]];
#         then
#             echo "HTTP Status Code Test Passed"
#         else
#             echo "HTTP Status code is not 200"
#             exit 1;
#     fi;

# else
#         echo "The Service does not have a NodePort"
#         exit 1;
# fi;