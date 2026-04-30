pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-clean"
        CLUSTER_NAME = "jenkins-cluster"
        KUBECONFIG = "/var/jenkins_home/.kubeconfig"
    }

    stages {

        stage('Detect Branch') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        env.ENV = 'dev'
                        env.RELEASE = 'react-dev'
                        env.VALUES = 'react-app/values-dev.yaml'
                    } else if (env.BRANCH_NAME == 'staging') {
                        env.ENV = 'staging'
                        env.RELEASE = 'react-staging'
                        env.VALUES = 'react-app/values-staging.yaml'
                    } else if (env.BRANCH_NAME == 'prod') {
                        env.ENV = 'prod'
                        env.RELEASE = 'react-prod'
                        env.VALUES = 'react-app/values-prod.yaml'
                    } else {
                        error("Unknown branch: ${env.BRANCH_NAME}")
                    }

                    // 🔥 FIX: Unique tag per build
                    env.TAG = "${env.ENV}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:${TAG} .
                '''
            }
        }

        stage('Load Image into KIND') {
            steps {
                sh '''
                kind load docker-image ${IMAGE_NAME}:${TAG} --name ${CLUSTER_NAME}
                '''
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh '''
                export KUBECONFIG=${KUBECONFIG}

                helm upgrade --install ${RELEASE} ./react-app \
                  -f ${VALUES} \
                  --set image.repository=${IMAGE_NAME} \
                  --set image.tag=${TAG}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                export KUBECONFIG=${KUBECONFIG}

                echo "=== Pods ==="
                kubectl get pods

                echo "=== Services ==="
                kubectl get svc
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful for ${env.RELEASE} with tag ${env.TAG}"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}