#!groovy
node {

    def dockerImage = null

    stage('Checkout') {
        checkout scm
        sh 'printenv'
    }

    stage('Build') {
        dockerImage = docker.build("rhaix/hugo-ubuntu")
    }

    stage('Push') {
        docker.withRegistry('', 'hub.docker.com-rhaix') {
            dockerImage.push()
        }
    }

}

