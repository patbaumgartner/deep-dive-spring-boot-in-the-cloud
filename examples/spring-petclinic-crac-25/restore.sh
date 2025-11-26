#!/bin/bash
set -e

docker run --rm --cap-add CHECKPOINT_RESTORE --cap-add SYS_ADMIN -p 8080:8080 --name spring-petclinic-crac-25 spring-petclinic-crac-25:checkpoint