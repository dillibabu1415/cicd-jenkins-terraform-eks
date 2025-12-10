pipeline {
    agent any

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
        TF_DIR                = 'terraform'   // 👈 UPDATE this to the actual path containing .tf files
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/dillibabu1415/cicd-jenkins-terraform-eks.git'
            }
        }

        stage('Diagnose repository layout') {
            steps {
                sh '''
                  echo "PWD: $(pwd)"
                  echo "Top level:"
                  ls -la
                  echo "Terraform dir contents ($TF_DIR):"
                  ls -la "$TF_DIR" || true
                  echo "Find *.tf within 3 levels:"
                  find . -name "*.tf" -maxdepth 3 -print || true
                '''
            }
        }

        stage('Validate Terraform directory') {
            steps {
                sh '''
                  set -e
                  if [ ! -d "$TF_DIR" ]; then
                    echo "ERROR: TF_DIR=$TF_DIR does not exist."
                    exit 1
                  fi
                  TF_COUNT=$(find "$TF_DIR" -maxdepth 1 -name "*.tf" | wc -l)
                  if [ "$TF_COUNT" -eq 0 ]; then
                    echo "ERROR: No .tf files found in $TF_DIR. Update TF_DIR to the correct path."
                    echo "Tip: Check the previous stage output to find where your *.tf files are."
                    exit 1
                  fi
                '''
            }
        }

        stage('Initialize Terraform') {
            steps {
                sh '''
                  set -e
                  terraform -chdir="$TF_DIR" init -upgrade
                '''
            }
        }

        stage('Validate') {
            steps {
                sh '''
                  set -e
                  terraform -chdir="$TF_DIR" validate
                '''
            }
        }

        stage('Plan') {
            steps {
                sh '''
                  set -e
                  terraform -chdir="$TF_DIR" plan -input=false -out=tfplan
                  terraform -chdir="$TF_DIR" show -no-color tfplan
                '''
            }
        }

        stage('Approve & Execute') {
            steps {
                input message: "Approve to ${params.ACTION} the EKS cluster?", ok: "Proceed"
                sh '''
                  set -e
                  if [ "${ACTION}" = "apply" ]; then
                    terraform -chdir="$TF_DIR" apply -input=false -auto-approve tfplan
                  else
                    terraform -chdir="$TF_DIR" destroy -input=false -auto-approve
                  fi
                '''
            }
        }
    }
}
