== Loadbalancer
Als je een loadbalancer wilt gebruiken kan dat met haproxy
Zie haprox-2.4 voor configuratie en voeg onderstaand toe aan compose yaml file:

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

