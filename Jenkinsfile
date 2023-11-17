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
        always {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
      }
      }
    }

    stage('Mutation Test PIT') {
      steps{
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }

  }
}