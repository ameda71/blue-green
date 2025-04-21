pipeline {
    agent any
    environment {
        ZONE = "us-central1-c"
        IMAGE_NAME = "bule-green"
        CLUSTER_NAME = "cluster-2"
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-key')
        GREEN_DEPLOY = "k8s/green.yaml"
        BLUE_DEPLOY = "k8s/blue.yaml"
        SVC="k8s/svc.yaml"
    }

    stages {
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', 
                                                  usernameVariable: 'DOCKER_USER', 
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('GCP Login') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                    # Authenticate with Google Cloud
                    echo "Using credentials from: $GOOGLE_APPLICATION_CREDENTIALS"
                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                    '''
                }
            }
        }

        stage('Build Docker Images (Blue & Green)') {
            steps {
                sh '''
                # Build Blue
                docker build -t $IMAGE_NAME-blue -f app/blue/Dockerfile app/blue
                docker tag $IMAGE_NAME-blue saiteja562/$IMAGE_NAME:blue-$BUILD_NUMBER

                # Build Green
                docker build -t $IMAGE_NAME-green -f app/green/Dockerfile app/green
                docker tag $IMAGE_NAME-green saiteja562/$IMAGE_NAME:green-$BUILD_NUMBER
                '''
            }
        }

        stage('Push Docker Images') {
            steps {
                sh '''
                docker push sukanya996/$IMAGE_NAME:blue-$BUILD_NUMBER
                docker push sukanya996/$IMAGE_NAME:green-$BUILD_NUMBER
                '''
            }
        }

        stage('Update Deployment Files') {
            steps {
                sh '''
                sed -i "s|image: .*|image: saiteja562/${IMAGE_NAME}:green-${BUILD_NUMBER}|" $GREEN_DEPLOY
                sed -i "s|image: .*|image: saiteja562/${IMAGE_NAME}:blue-${BUILD_NUMBER}|" $BLUE_DEPLOY
                '''
            }
        }

        stage('Terraform Apply (Cluster)') {
            steps {
                script {
                    // Change to the directory containing the Terraform configuration files
                    dir('terraform') {
                        sh '''
                        terraform init
                        terraform plan
                        terraform apply --auto-approve
                        '''
                    }
                }
            }
        }

        stage('Wait for Cluster Access') {
            steps {
                retry(3) {
                    sh '''
                    sleep 20
                    gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project manisai
                    '''
                }
            }
        }

        stage('Deploy to Green') {
            steps {
                sh 'kubectl apply -f $BLUE_DEPLOY'
                sh 'kubectl apply -f $GREEN_DEPLOY'
                sh 'kubectl apply -f $SVC'
                sh 'sleep 50'
                sh 'kubectl get svc'
                sh 'sleep 20'
                
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh '''
                kubectl patch svc flask-service -p '{"spec": {"selector": {"app": "flask", "version": "green"}}}'
                '''
            }
        }

        stage('Delete Blue Deployment (Optional)') {
            steps {
                sh '''
                kubectl delete -f $BLUE_DEPLOY || echo "No blue deployment found"
                '''
            }
        }

        stage('Get Service') {
            steps {
                sh 'kubectl get svc'
            }
        }
    }
}
