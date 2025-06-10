pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/vamshireddy903/Terraform-CI-CD.git'
            }
        }

        stage('Terraform Operations') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-cred', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        echo "=== Terraform Init ==="
                        terraform init

                        echo "=== Terraform Plan ==="
                        terraform plan -out=tfplan

                        echo "=== Terraform Apply ==="
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                input message: 'Do you want to destroy the infrastructure?', ok: 'Yes, Destroy'
                withCredentials([usernamePassword(credentialsId: 'aws-cred', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}
