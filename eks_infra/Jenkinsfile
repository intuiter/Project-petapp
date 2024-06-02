pipeline {
    agent any
    environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-aws-credentialkeys')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-credentialkeys')
            }
    parameters {
        choice(
            choices: 'master', 
            name: 'BRANCH_NAME'
        ) 
    }        

    stages { 

        //==========================================INFRA-PIPELINE======================================

        stage ('Provision eks- Terraform init') {
            steps {  
                echo 'initializing terraform' 
                script {
                    dir ('Infr_eks') {
                        bat 'terraform init'
                    }
                }
            }  
        }
        stage ('Provision eks- Terraform plan') {
            steps {  
                echo 'terraform plan' 
                script {
                    dir ('Infr_eks') {
                        bat 'terraform plan'
                    }
                }
            }  
        }
        stage ('Provision eks- Terraform apply') {
            steps {  
                when {
                 expression {
                    return params.BRANCH_NAME == 'master'}
                }
                echo 'applying terraform code' 
                script {
                    dir ('Infr_eks') {
                        bat 'terraform $action -auto-approve'
                    }
                }
            }  
        }
        stage ('Update kube-config') {
            steps {  
                echo 'updating to eks kube-config' 
                script {
                    dir ('Infr_eks/K8sConfigfiles') {
                        bat 'aws eks update-kubeconfig --name pet-clinic'
                    }
                }
            }  
        }
    }
}   