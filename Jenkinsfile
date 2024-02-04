pipeline{
  agent any

  stages{
    stage("A"){
      steps{
          // echo "========executing A========"
        script {            
          dockerImage = docker.build("244586165116.dkr.ecr.ca-central-1.amazonaws.com/pack_broker:${BUILD_ID}")
          docker.withRegistry('https://244586165116.dkr.ecr.ca-central-1.amazonaws.com', 'ecr:ca-central-1:aws-credentials-gigi-admin'){
            dockerImage.push()
          }
        }   
      }
    }
  }
}