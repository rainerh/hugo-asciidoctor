#!groovy
node {

    def dockerImage = null

    stage('Checkout') {
        checkout scm
    }

    stage('Build') {
        dockerImage = docker.build("rgielen/hugo-ubuntu")
    }

    stage('Push') {
        docker.withRegistry('', 'hub.docker.com-rgielen') {
            dockerImage.push()
        }
    }

}

