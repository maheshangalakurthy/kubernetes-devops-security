// @Library('slack') _

pipeline {
  agent any
  stages {
    stage('Maven Build Artifacts') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts 'target/*.jar'  
      }
    }
    stage ('JUnit Testing and Jacoco') {
      steps {
        sh "mvn test"
      }
      post {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
      }
    }

  }
}