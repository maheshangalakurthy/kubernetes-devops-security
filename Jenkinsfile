pipeline {
  agent any

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
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
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

      // stage('SonarQube - SAST') {
      //   steps {
      //     withSonarQubeEnv('SonarQube') {
      //    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application' -Dsonar.host.url=http://devsecops-proj.eastus.cloudapp.azure.com:9000 -Dsonar.token=sqp_daf89bfec6df30c869e1cba12b7683c74b607602"
      //   }
      //   timeout(time: 2, unit: 'MINUTES') {
      //     script {
      //       waitForQualityGate abortPipeline: true
      //     }
      //   }
      //  }
      // }
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
        sh "mvn dependency-check:check"
      }
      post {
        always {
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
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

      stage('K8S Deployment') {
        steps {
          withKubeConfig([credentialsId: "kubeconfig"]) {
            sh "kubectl config current-context"
            sh "sed -i 's#replace#angalakurthymahesh/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    }
}