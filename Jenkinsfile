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