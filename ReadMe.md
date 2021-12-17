#Three node MarkLogic cluster on a single VM
Here is an example of the marklogic-3n-centos.yaml, mldb_admin_username.txt, and mldb_admin_password.txt files that need to be created in your host machine before running the Docker compose command.

marklogic-3n-centos.yaml

#Docker compose file sample to setup a three node MarkLogic cluster

version: '3.6'

services:
    bootstrap:
      image: PLACEHOLDER-FOR-DOCKER-IMAGE:DOCKER-TAG
      container_name: bootstrap
      dns_search: ""
      environment:
        - MARKLOGIC_INIT=true
        - MARKLOGIC_ADMIN_USERNAME_FILE=mldb_admin_username
        - MARKLOGIC_ADMIN_PASSWORD_FILE=mldb_admin_password
        - TZ=Europe/Prague
      volumes:
        - ~/data/MarkLogic1:/var/opt/MarkLogic
      secrets:
          - mldb_admin_password
          - mldb_admin_username
      ports:
        - 7100-7110:8000-8010
        - 7197:7997
      networks:
      - external_net
    node2:
      image: PLACEHOLDER-FOR-DOCKER-IMAGE:DOCKER-TAG
      container_name: node2
      dns_search: ""
      environment:
        - MARKLOGIC_INIT=true
        - MARKLOGIC_ADMIN_USERNAME_FILE=mldb_admin_username
        - MARKLOGIC_ADMIN_PASSWORD_FILE=mldb_admin_password
        - MARKLOGIC_JOIN_CLUSTER=true
        - TZ=Europe/Prague
      volumes:
        - ~/data/MarkLogic2:/var/opt/MarkLogic
      secrets:
        - mldb_admin_password
        - mldb_admin_username
      ports:
        - 7200-7210:8000-8010
        - 7297:7997
      depends_on:
      - bootstrap
      networks:
      - external_net
    node3:
      image: PLACEHOLDER-FOR-DOCKER-IMAGE:DOCKER-TAG
      container_name: node3
      dns_search: ""
      environment:
        - MARKLOGIC_INIT=true
        - MARKLOGIC_ADMIN_USERNAME_FILE=mldb_admin_username
        - MARKLOGIC_ADMIN_PASSWORD_FILE=mldb_admin_password
        - MARKLOGIC_JOIN_CLUSTER=true
        - TZ=Europe/Prague
      volumes:
        - ~/data/MarkLogic3:/var/opt/MarkLogic
      secrets:
        - mldb_admin_password
        - mldb_admin_username
      ports:
        - 7300-7310:8000-8010
        - 7397:7997
      depends_on:
      - bootstrap
      networks:
      - external_net

secrets:
  mldb_admin_password:
    file: ./mldb_admin_password.txt
  mldb_admin_username:
    file: ./mldb_admin_username.txt
networks:
  external_net: {}
mldb_admin_username.txt

#This file will contain the MARKLOGIC_ADMIN_USERNAME value

<insert admin username>
mldb_admin_password.txt

#This file will contain the MARKLOGIC_ADMIN_PASSWORD value

<insert admin password>
Once the files are ready, run the following command to start the MarkLogic container.

$ docker-compose -f marklogic-3n-centos.yaml up -d
After the container is initialized, you can access the QConsole on http://localhost:8000 and the Admin UI on http://localhost:8001. The ports can also be accessed externally via your hostname or IP.

As with the single node example, each node of the cluster can be accessed with localhost or host machine IP. QConsole and Admin UI ports for each container are different, as defined in the Docker compose file: http://localhost:7101, http://localhost:7201, http://localhost:7301, etc.

The node2, node3 use MARKLOGIC_JOIN_CLUSTER to join the cluster once they are running.