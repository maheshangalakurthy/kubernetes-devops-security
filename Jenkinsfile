pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }   
       stage('Unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
       stage('Docker Build and Push') {
        steps {
          sh 'printenv'
          sh 'sudo docker build -t angalakurthymahesh/numeric-app:""$GIT_COMMIT"" .'
          sh 'sudo docker push angalakurthymahesh/numeric-app:""$GIT_COMMIT""'
        }
       }   
    }
}