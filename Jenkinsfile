#!groovy
node {

    def dockerImage = null

    stage('Checkout') {
        checkout scm
        sh 'printenv'
    }

    stage('Build') {
        hugoDockerImage = docker.build("rhaix/hugo", "-f Dockerfile .")
        asciidoctorDockerImage = docker.build("rhaix/hugo-asciidoctor", "-f Dockerfile.asciidoctor .")
    }

    stage('Push') {
        docker.withRegistry('', 'hub.docker.com-rhaix') {
            hugoDockerImage.push()
            asciidoctorDockerImage.push()
        }
    }

}

