pipeline {
    agent any

    environment {
        // Thay đổi thông tin của bạn tại đây
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-login' 
        DOCKER_IMAGE = "23127193/flask-app" // Thay bằng username Docker Hub của bạn
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. Build Docker Image') {
            steps {
                // Sử dụng biến môi trường BUILD_NUMBER của Jenkins để đánh tag phiên bản
                sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('3. Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'DUSER', passwordVariable: 'DPASS')]) {
                    sh "echo ${DPASS} | docker login -u ${DUSER} --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('4. Deploy to Local Docker') {
            steps {
                script {
                    // Dừng và xóa container cũ nếu đang chạy để tránh trùng port/tên
                    sh "docker stop my-flask-app || true"
                    sh "docker rm my-flask-app || true"
                    
                    // Chạy container mới trực tiếp trên máy local
                    sh "docker run -d --rm --name my-flask-app -p 5000:5000 ${DOCKER_IMAGE}:latest"
                    
                    echo "Ứng dụng đã được deploy thành công tại http://localhost:5000"
                }
            }
        }
    }

    post {
        always {
            // Đăng xuất để bảo mật
            sh "docker logout"
        }
        success {
            echo "Chúc mừng! Pipeline đã chạy thành công."
        }
        failure {
            echo "Pipeline thất bại. Kiểm tra lại Logs của Stage tương ứng."
        }
    }
}
