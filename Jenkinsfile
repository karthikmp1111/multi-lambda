pipeline {
    agent any

    environment {
        AWS_REGION = "us-west-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karthikmp1111/multi-lambda.git'
            }
        }

        stage('Detect Changes') {
            steps {
                script {
                    def changedFiles = sh(script: "git diff --name-only HEAD~1", returnStdout: true).trim()
                    env.LAMBDA1_CHANGED = changedFiles.contains("lambda-functions/lambda1/")
                    env.LAMBDA2_CHANGED = changedFiles.contains("lambda-functions/lambda2/")
                    env.TERRAFORM_CHANGED = changedFiles.contains("terraform/")
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.TERRAFORM_CHANGED == 'true' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy Lambda Functions') {
            parallel {
                stage('Deploy Lambda1') {
                    when {
                        expression { env.LAMBDA1_CHANGED == 'true' }
                    }
                    steps {
                        sh 'bash scripts/deploy_lambda.sh lambda1'
                    }
                }
                stage('Deploy Lambda2') {
                    when {
                        expression { env.LAMBDA2_CHANGED == 'true' }
                    }
                    steps {
                        sh 'bash scripts/deploy_lambda.sh lambda2'
                    }
                }
            }
        }

        stage('Approval for Destroy') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                input message: 'Do you want to destroy the infrastructure?', ok: 'Proceed'
            }
        }

        stage('Destroy Infrastructure') {
            when {
                expression { return params.DESTROY }
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
                sh 'bash scripts/destroy_lambda.sh lambda1'
                sh 'bash scripts/destroy_lambda.sh lambda2'
            }
        }
    }
}
