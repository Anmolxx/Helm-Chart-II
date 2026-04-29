pipeline {
    agent any

    environment {
        KUBECONFIG = "/var/jenkins_home/.kubeconfig"
        IMAGE_NAME = "react-clean"
        TAG = "${BRANCH_NAME}"
    }

    stages {

        stage('Detect Branch') {
            steps {
                script {
                    if (env.BRANCH_NAME == "dev") {
                        env.RELEASE = "react-dev"
                        env.VALUES = "react-app/values-dev.yaml"
                    } else if (env.BRANCH_NAME == "staging") {
                        env.RELEASE = "react-staging"
                        env.VALUES = "react-app/values-staging.yaml"
                    } else {
                        env.RELEASE = "react-prod"
                        env.VALUES = "react-app/values-prod.yaml"
                    }
                }
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${TAG} ."
            }
        }

        stage('Deploy') {
            steps {
                sh """
                helm upgrade --install ${RELEASE} ./react-app \
                -f ${VALUES} \
                --set image.repository=${IMAGE_NAME} \
                --set image.tag=${TAG}
                """
            }
        }

        stage('Verify') {
            steps {
                sh "kubectl get pods"
            }
        }
    }
}