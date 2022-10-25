@set IMAGE_NAME=swift-request

docker run -it --rm --name swift-request -p 8080:8080 %IMAGE_NAME% /bin/bash
