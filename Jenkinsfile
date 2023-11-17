// @Library('slack') _

pipeline {
  agent any
  stages {
    stage('Build Artifacts') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts 'target/*.jar' 
      }
    }
  }
}