#!/bin/bash
set -e

source "$HOME/.sdkman/bin/sdkman-init.sh"
sed -i s"/sdkman_auto_answer=false/sdkman_auto_answer=true/" ~/.sdkman/etc/config

sdk default java 25.0.2-zulu

case $(uname -m) in
    arm64)   url="https://cdn.azul.com/zulu/bin/zulu25.32.21-ca-crac-jdk25.0.2-linux_aarch64.tar.gz" ;;
    *)       url="https://cdn.azul.com/zulu/bin/zulu25.32.21-ca-crac-jdk25.0.2-linux_x64.tar.gz" ;;
esac

echo "Using CRaC enabled JDK $url"

./mvnw clean package

docker build -t spring-petclinic-crac-25:builder --build-arg CRAC_JDK_URL=$url .

docker run -d --privileged --rm --name=spring-petclinic-crac-25 --ulimit nofile=1024 -p 8080:8080 -v $(pwd)/target:/opt/mnt -e FLAG=$1 spring-petclinic-crac-25:builder

echo "Please wait during creating the checkpoint..."
sleep 10

docker commit --change='ENTRYPOINT ["/opt/app/entrypoint.sh"]' $(docker ps -alqf "name=spring-petclinic-crac-25") spring-petclinic-crac-25:checkpoint

docker kill $(docker ps -aqlf "name=spring-petclinic-crac-25")
