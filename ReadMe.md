# Three node MarkLogic cluster with haproxy LB on a single VM

This project is used to setup a 3 node marklogic cluster with a load balancer 

It uses the marklogic-3n-centos.yaml, mldb_admin_username.txt, mldb_admin_password.txt and haproxy-2.4/haproxy.cfg files.
There are 2 shell scripts to start and stop teh container.
In the docs folder there is an asciidoc file describing the steps to take after the container with the cluster is ready.

**Docker compose file sample to setup a three node MarkLogic cluster with haproxy LB**
```
version: '3.8'

services:
  bootstrap:
    image: store/marklogicdb/marklogic-server:${mlVersionTag}
    hostname: "mlcup_node0.local"
    container_name: "mlcup_node0.local"
    dns_search: ""
    environment:
      - MARKLOGIC_INIT=true
      - MARKLOGIC_ADMIN_USERNAME_FILE=mldb_admin_username
      - MARKLOGIC_ADMIN_PASSWORD_FILE=mldb_admin_password
      - TZ=Europe/Prague
    volumes:
      - ./data/MarkLogic1:/var/opt/MarkLogic
    secrets:
      - mldb_admin_password
      - mldb_admin_username
    ports:
      - 7100-7110:8000-8010
      - 7197:7997
    networks:
    - external_net
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 8G
    extra_hosts:
      host.docker.internal: host-gateway

  node1:
    image: store/marklogicdb/marklogic-server:${mlVersionTag}
    hostname: "mlcup_node1.local"
    container_name: "mlcup_node1.local"
    dns_search: ""
    environment:
      - MARKLOGIC_INIT=true
      - MARKLOGIC_ADMIN_USERNAME_FILE=mldb_admin_username
      - MARKLOGIC_ADMIN_PASSWORD_FILE=mldb_admin_password
      - MARKLOGIC_JOIN_CLUSTER=true
      - TZ=Europe/Prague
    volumes:
      - ./data/MarkLogic2:/var/opt/MarkLogic
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
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 8G
    extra_hosts:
      host.docker.internal: host-gateway

  node3:
    image: store/marklogicdb/marklogic-server:${mlVersionTag}
    hostname: "mlcup_node2.local"
    container_name: "mlcup_node2.local"
    dns_search: ""
    environment:
      - MARKLOGIC_INIT=true
      - MARKLOGIC_ADMIN_USERNAME_FILE=mldb_admin_username
      - MARKLOGIC_ADMIN_PASSWORD_FILE=mldb_admin_password
      - MARKLOGIC_JOIN_CLUSTER=true
      - TZ=Europe/Prague
    volumes:
      - ./data/MarkLogic3:/var/opt/MarkLogic
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
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 6G
    extra_hosts:
      host.docker.internal: host-gateway
  haproxy:
    image: haproxytech/haproxy-alpine:2.4
    #restart: always
    hostname: "haproxy"
    container_name: "haproxy"
    volumes:
      - ./haproxy-2.4:/usr/local/etc/haproxy/
    ports:
      - "8000-8010:8000-8010"
      - "8404:8404"
    expose:
      - "8000-8010"
    networks:
      - external_net
    depends_on:
    - node3
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 256M

secrets:
  mldb_admin_password:
    file: ./mldb_admin_password.txt
  mldb_admin_username:
    file: ./mldb_admin_username.txt
networks:
  external_net:
    driver: bridge
```

Administrative username and password can be provided through below two files:

**This file will contain the MARKLOGIC_ADMIN_USERNAME value**

mldb_admin_username.txt
```shell
<insert admin username>
```
**This file will contain the MARKLOGIC_ADMIN_PASSWORD value**

mldb_admin_password.txt
```shell
<insert admin password>
```

Prepare a .env file that docker compose can use to provide environment valiarble to the scipts.
```shell
DOCKERPROJECT=metrotest
mlVersionTag=10.0-8.1-centos-1.0.0-ea2
```

The DOCKERPROJECT parameter will group your containers in a recognisable project name in docker. 

The mlVersionTag refers to the tag of the MarkLogic docker image on dockerhub. +

To be able to pull images from dockerhub you need to login to dockerhub once from the commandline
```shell
docker login  -u user_name
```

### Starting the containers in the project

Once you are logged in you can start your docker container with the provides start.sh shell script

```shell
./start.sh
```
After the container is initialized, you can access the QConsole on http://localhost:8000 and the Admin UI on http://localhost:8001 via the haproxy load balancer. The ports can also be accessed externally via your hostname or IP.

As with the single node example, each node of the cluster can be accessed with localhost or host machine IP. QConsole and Admin UI ports for each container are different, as defined in the Docker compose file: http://localhost:7101, http://localhost:7201, http://localhost:7301, etc.

The node2 and node3 use MARKLOGIC_JOIN_CLUSTER property to join the cluster once they are running.

### Splitting the voter node to a separate group

Run the following commands to move the voter node to a separate voter group

```shell
./scripts/create_group.sh -p admin localhost Voter

./scripts/join_group.sh -p admin localhost mlcup_node2.local Voter
```

### Replicating the system database forests

Run the following cmmand to create ana attach replica forests to the system database forests.

```shell
./scripts/create-system_db_replicas.sh -p admin localhost mlcup_node1.local App-Services Triggers Modules Schemas Security Meters
```

### Stopping the containers in the project

The following command will stop the nodes 
```shell
./stop.sh
```

### Removing the project

The following command will stop the containers and removes all containers, networks, images and volumes created by the project.
```shell
./stop.sh
```

**Attention**

The MarkLogic data files will be persisted in the subfolder ./data/[ml-node]
So if you want to completely remove the project plus the data files you need to remove the subfolders inside the data folder!

