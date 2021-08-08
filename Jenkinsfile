@Library('shared-notifi-slack')_

pipeline {
     environment {
       IMAGE_NAME = "webapp-static"
       IMAGE_TAG = "latest"
       STAGING = "webapp-static-staging"
       PRODUCTION = "webapp-static-production"
       DOCKERHUB_CREDENTIALS = credentials('dockerhub')
     }
     agent none
     stages {
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t maroki92/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
        stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    docker run --name $IMAGE_NAME -d -p 80:80 -e PORT=80 maroki92/$IMAGE_NAME:$IMAGE_TAG
                    sleep 20
                 '''
               }
            }
       }
       stage('Test') {
           agent any
           steps {
             snykSecurity(
               snykInstallation: 'snyk@latest',
               snykTokenId: 'snyk-api-token',
             )
          }
       }          
       stage('Test image') {
           agent any
            steps {
              script {
                sh '''
                    curl http://172.17.0.1 | grep -q "Dimension"
                '''
              }
           }
      }
      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }

     stage ('Login and Push Image') {
       agent any
       steps {
         script {
            sh '''
              echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
              docker push maroki92/$IMAGE_NAME:$IMAGE_TAG
            '''
         }
       }
     }
     stage('Push image in staging and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/main' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              heroku container:login
              heroku create $STAGING || echo "project already exist"
              heroku container:push -a $STAGING web
              heroku container:release -a $STAGING web
            '''
          }
        }
     }
     stage('Push image in production and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/main' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              heroku container:login
              heroku create $PRODUCTION || echo "project already exist"
              heroku container:push -a $PRODUCTION web
              heroku container:release -a $PRODUCTION web
            '''
          }
        }
     }
  }
  post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }  
  }
}
