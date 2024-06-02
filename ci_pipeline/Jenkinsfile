pipeline {
    agent any
    // tools{
    //     maven 'maven_tool'
    // }

    environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-awsaccesskeys')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-secretaccesskeys')
                DOCKERHUB_USERNAME = "medha754"
                APP_NAME = "petclinic-01"
                IMAGE_TAG = "${BUILD_NUMBER}"
                ECRURL = "https://818104450483.dkr.ecr.us-east-1.amazonaws.com/pc-ecr"
                ECR_REGISTRY = "818104450483.dkr.ecr.us-east-1.amazonaws.com/pc-ecr"
                //ECR_IMAGE_NAME = "pc-ecr"
            }
     parameters {       
     string(name: 'ECRURL', defaultValue: 'https://818104450483.dkr.ecr.us-east-1.amazonaws.com/', description: 'Please Enter your Docker ECR REGISTRY URL?')
     string(name: 'REPO', defaultValue: 'pc-ecr', description: 'Please Enter your Docker Repo Name?')
     string(name: 'REGION', defaultValue: 'us-east-1', description: 'Please Enter your AWS Region?')
    }


    stages {

    stage('Checkout') {
      steps {
        sh 'echo passed'
        //git branch: 'master', url: 'https://github.com/intuiter/ci_pipeline.git'
      }
    }
        stage ('Build jar') {
            steps {  
                echo 'Building jar' 
                script {
                    dir ('application-code-g') {
                        sh 'mvn clean package -DskipTests,spring.profiles.active=mysql'
                    }
                }
            }  
        }

        stage('Code Analysis with Sonarqube') {
      environment {
        SONAR_URL = "http://52.91.184.177:9000"
      }
      steps {
        withCredentials([string(credentialsId: 'sonar-cred', variable: 'SONAR_TOKEN')]) {
          sh 'cd application-code-g && mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN -Dsonar.host.url=${SONAR_URL}'
        }
      }
    }
        
        stage('Stage Artifacts to Jfrog') {
                steps {
                    script {
                        def server = Artifactory.server 'jfrog-serve' 
                        def uploadSpec = """{    
                            "files": [{
                            "pattern": "/var/lib/jenkins/workspace/CI-pipeline/application-code-g/target/spring-petclinic-3.1.0-SNAPSHOT.jar", 
                            "target": "my-jfrog",
                            "recursive": "false"        
                            }]
                        }"""   
                        server.upload(uploadSpec)       
                    }
            }
        } 
        stage ('Docker Image Build') {  
            steps {
                    script {   
                        dir ('application-code-g') {
                            dockerTag = params.REPO + ":" + "${IMAGE_TAG}"
                            docker.withRegistry( params.ECRURL, 'ecr:us-east-1:aws-cred' ) {
                            myImage = docker.build(dockerTag)
                        }
                    }
                }
            }  
        }
        
        stage ('Docker scan with TRIVY') {  
            steps {
                    script {   
                        dir ('application-code-g') {
                            sh ("docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/tmp/.cache/ aquasec/trivy:0.10.0 ${params.REPO}:${IMAGE_TAG}")
                    }
                }
            }
        }
        stage('Explore Image Layers with DIVE') { 
            steps { 
                script {
                    env.dockerTag = params.REPO + ":" + "${IMAGE_TAG}"
                    sh "docker run --rm -i \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        wagoodman/dive:latest --ci ${dockerTag} --lowestEfficiency=0.8 --highestUserWastedPercent=0.45"
                }                        
            }            
        }
        stage ('Docker image Push to ECR') {  
            steps {
                    script {   
                        dir ('application-code-g') {
                            dockerTag = params.REPO + ":" + "${IMAGE_TAG}"
                            docker.withRegistry( params.ECRURL, 'ecr:us-east-1:aws-cred' ) {
                            myImage.push()
                        }
                    }
                }
            }  
        }    
        stage ('Clean docker images') {
            steps {  
                echo 'Cleaning the docker images' 
                script {
                        dir ('application-code-g') {
                        sh ("docker rmi ${params.REPO}:${IMAGE_TAG}")
                        sh ("docker rmi ${ECR_REGISTRY}:${IMAGE_TAG}")
                    }
                }
            } 
        }
        stage ('Trigger cd pipeline') {
            steps {  
                echo 'Triggering cd pipeline' 
                script {
                        sh """
                                curl http://54.227.25.10:8080/job/CD-pipeline/buildWithParameters?token=gitops-token \
                                    --user admin:11978b8123651c6e39ea506ff1b02d9c95 \
                                    --data IMAGE_TAG=${IMAGE_TAG} --data verbosity=high \
                                    -H content-type:application/x-www-form-urlencoded \
                                    -H cache-control:no-cache
                            """
                    }
                }
        } 
   
    } 
}

