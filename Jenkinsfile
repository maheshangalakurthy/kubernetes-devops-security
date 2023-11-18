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
    }

    stage('Mutation Test PIT') {
      steps{
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
    }

    stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://34.27.27.66:9000"
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }

    	stage('Vulnerability Scan for Dependency and Docker Base Image') {
      steps {
        parallel(
        	"Dependency Scan": {
        		sh "mvn dependency-check:check"
			},
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          }
			
      	)
      }
    }

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'sudo docker build -t angalakurthymahesh/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push angalakurthymahesh/numeric-app:""$GIT_COMMIT""'
        }
      }
    }

  }

  post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
    }

    // success{

    // }

    // failure {

    // }
  }
}