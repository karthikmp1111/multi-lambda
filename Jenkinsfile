// pipeline {
//     agent any

//     environment {
//         AWS_REGION = 'us-west-1'
//     }

//     parameters {
//         choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform resources')
//     }

//     stages {
//         stage('Checkout Code') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/karthikmp1111/multi-lambda.git'
//             }
//         }

//         stage('Setup AWS Credentials') {
//             steps {
//                 withCredentials([
//                     string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
//                     string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
//                 ]) {
//                     sh '''
//                     aws configure set aws_access_key_id $AWS_ACCESS_KEY
//                     aws configure set aws_secret_access_key $AWS_SECRET_KEY
//                     aws configure set region $AWS_REGION
//                     '''
//                 }
//             }
//         }

//         stage('Build Lambda Packages') {
//             steps {
//                 script {
//                     def lambdas = ["lambda1", "lambda2", "lambda3"]
//                     lambdas.each { lambdaName ->
//                         if (sh(script: "git diff --quiet HEAD~1 lambda-functions/${lambdaName}", returnStatus: true) != 0) {
//                             sh "bash lambda-functions/${lambdaName}/build.sh"
//                         } else {
//                             echo "No changes detected in ${lambdaName}, skipping build."
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Terraform Init') {
//             steps {
//                 dir('terraform') {
//                     sh 'terraform init'
//                 }
//             }
//         }

//         stage('Terraform Plan') {
//             steps {
//                 dir('terraform') {
//                     sh 'terraform plan'
//                 }
//             }
//         }

//         stage('Terraform Apply') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'apply' }
//             }
//             steps {
//                 dir('terraform') {
//                     sh 'terraform apply -auto-approve'
//                 }
//             }
//         }

//         stage('Terraform Destroy') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'destroy' }
//             }
//             steps {
//                 dir('terraform') {
//                     sh 'terraform destroy -auto-approve'
//                 }
//             }
//         }
//     }
// }


// pipeline {
//     agent any

//     environment {
//         AWS_REGION = 'us-west-1'
//     }

//     parameters {
//         choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform resources')
//     }

//     stages {
//         stage('Checkout Code') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/karthikmp1111/multi-lambda.git'
//             }
//         }

//         stage('Setup AWS Credentials') {
//             steps {
//                 withCredentials([
//                     string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
//                     string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
//                 ]) {
//                     sh '''
//                     aws configure set aws_access_key_id $AWS_ACCESS_KEY
//                     aws configure set aws_secret_access_key $AWS_SECRET_KEY
//                     aws configure set region $AWS_REGION
//                     '''
//                 }
//             }
//         }

//         stage('Build Lambda Packages') {
//             steps {
//                 script {
//                     def lambdas = ["lambda1", "lambda2", "lambda3"]
//                     lambdas.each { lambdaName ->
//                         if (sh(script: "git diff --quiet HEAD~1 lambda-functions/${lambdaName}", returnStatus: true) != 0) {
//                             sh "bash lambda-functions/${lambdaName}/build.sh"
//                         } else {
//                             echo "No changes detected in ${lambdaName}, skipping build."
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Terraform Init') {
//             steps {
//                 dir('terraform') {
//                     sh 'terraform init'
//                 }
//             }
//         }

//         stage('Terraform Plan') {
//             steps {
//                 dir('terraform') {
//                     sh 'terraform plan -out=tfplan'
//                 }
//             }
//         }

//         stage('Terraform Apply') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'apply' }
//             }
//             steps {
//                 dir('terraform') {
//                     sh 'terraform apply -auto-approve tfplan'
//                 }
//             }
//         }

//         stage('Terraform Destroy') {
//             when {
//                 expression { params.APPLY_OR_DESTROY == 'destroy' }
//             }
//             steps {
//                 dir('terraform') {
//                     sh 'terraform destroy -auto-approve'
//                 }
//             }
//         }

//         stage('Clean Workspace') {
//             steps {
//                 cleanWs()
//             }
//         }
//     }
// }


pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-1'
        S3_BUCKET = 'bg-kar-terraform-state'
        // Change this line to a valid string or use def to declare the list inside script block
        LAMBDA_FUNCTIONS = "lambda1,lambda2,lambda3"  // Use comma-separated string instead of Groovy list
    }

    parameters {
        choice(name: 'APPLY_OR_DESTROY', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform resources')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/karthikmp1111/multi-lambda.git'
            }
        }

        stage('Setup AWS Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_KEY')
                ]) {
                    sh '''
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY
                    aws configure set aws_secret_access_key $AWS_SECRET_KEY
                    aws configure set region $AWS_REGION
                    '''
                }
            }
        }

        stage('Build and Upload Lambda Packages') {
            steps {
                script {
                    def lambdas = ['lambda1', 'lambda2', 'lambda3']  // Define it here as Groovy list
                    lambdas.each { lambdaName ->
                        if (sh(script: "git diff --quiet HEAD~1 lambda-functions/${lambdaName}", returnStatus: true) != 0) {
                            sh "bash lambda-functions/${lambdaName}/build.sh"
                            // Upload to S3 after building the package
                            sh "aws s3 cp lambda-functions/${lambdaName}/package.zip s3://$S3_BUCKET/lambda-packages/${lambdaName}/package.zip"
                        } else {
                            echo "No changes detected in ${lambdaName}, skipping build and upload."
                        }
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.APPLY_OR_DESTROY == 'apply' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.APPLY_OR_DESTROY == 'destroy' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
    }
}
