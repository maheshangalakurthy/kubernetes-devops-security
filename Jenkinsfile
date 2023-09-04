pipeline {
  agent any
   environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "siddharth67/numeric-app:${GIT_COMMIT}"
    applicationURL="http://devsecops-demo.eastus.cloudapp.azure.com"
    applicationURI="/increment/99"
  }
  
  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }   
       stage('Unit Tests and JoCoCo') {
            steps {
              sh "whoami"
              sh "mvn test"
            }
            // post {
            //   always {
            //     junit 'target/surefire-reports/*.xml'
            //     jacoco execPattern: 'target/jacoco.exec'
            //   }
            // }
        }

       stage('Mutation Tests - PIT') {
        steps {
          sh "mvn org.pitest:pitest-maven:mutationCoverage"
        }
        post {
          always {
            // pitmutation mutationStatsFile: 'target/pit-reports/**/mutations.xml'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
       }

     
      stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://devsecops-proj.eastus.cloudapp.azure.com:9000"
        }
      }
    }
    stage('Sonarqube quality gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
   
    stage('Vulnerability Scan - Docker') {
      steps {
        parallel(
          "Dependency Scan": {
            sh "mvn dependency-check:check"
          },
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest":{
				    sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
			}   
        )
      }
    }
       stage('Docker Build and Push') {
        steps {
         
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t angalakurthymahesh/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push angalakurthymahesh/numeric-app:""$GIT_COMMIT""'
        }
        }
       }   

       stage('Vulnerability Scan - Kubernetes') {
      steps {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
      }
    }
      // stage('K8S Deployment') {
      //   steps {
      //     withKubeConfig([credentialsId: "kubeconfig"]) {
      //       sh "kubectl config current-context"
      //       sh "sed -i 's#replace#angalakurthymahesh/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
      //       sh "kubectl apply -f k8s_deployment_service.yaml"
      //     }
      //   }
      // }

      //    stage('K8S Deployment - PROD') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
              sh "kubectl -n prod apply -f k8s_PROD-deployment_service.yaml"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-PROD-deployment-rollout-status.sh"
            }
          }
        )
      }
    }

    }

    post {
        always {
           dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
          //  pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
           junit 'target/surefire-reports/*.xml'
           jacoco execPattern: 'target/jacoco.exec'
        }
      }
}