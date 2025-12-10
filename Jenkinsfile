pipeline {
    agent any

    // Choose whether to apply or destroy
    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose whether to create (apply) or destroy the EKS cluster'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                // Simple Git checkout (you can keep checkout scmGit if you prefer)
                git branch: 'main', url: 'https://github.com/dillibabu1415/cicd-jenkins-terraform-eks.git'
                // If you must use checkout scmGit, replace with your original block minus dir()
            }
        }

        stage('Initializing Terraform') {
            steps {
                sh '''
                  set -e
                  cd terraform
                  terraform init -upgrade
                '''
            }
        }

        stage('Validating Terraform') {
            steps {
                sh '''
                  set -e
                  cd terraform
                  terraform validate
                '''
            }
        }

        stage('Previewing the infrastructure (plan)') {
            steps {
                sh '''
                  set -e
                  cd terraform
                  terraform plan -input=false -out=tfplan
                  terraform show -no-color tfplan
                '''
            }
        }

        stage('Approve & Execute') {
            steps {
                input message: "Approve to ${params.ACTION} the EKS cluster?", ok: "Proceed"
                sh """
                  set -e
                  cd terraform
                  if [ "${params.ACTION}" = "apply" ]; then
                    terraform apply -input=false -auto-approve tfplan
                  else
                    terraform destroy -input=false -auto-approve
                  fi
                """
            }
        }
    }
 }
