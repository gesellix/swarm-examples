# Docker Swarm: Beispiele

Beispiel-Code zum Artikel "Continuous Deployment mit Docker Swarm" im [Java Magazin 12.17](https://entwickler.de/java-magazin/java-magazin-12-17-579817649.html).

_Update_: Der komplette Artikel ist jetzt unter [jaxenter.de](https://jaxenter.de/docker-swarm-einfuehrung-65263) online lesbar.

An English version of the article is available at [jaxenter.com](https://jaxenter.com/services-and-stacks-in-the-cluster-141399.html).

## Überblick

Die Beispiele setzen voraus, dass die lokale Docker Engine als Swarm Manager fungiert
und mindestens ein Worker, markiert mit dem Label `de.gesellix.swarm.node=worker`, im Swarm verfügbar ist.
Eine solche Umgebung kann wie unter [Lokale Testumgebung](#lokale-testumgebung) beschrieben
eingerichtet werden.

Im Artikel wird der Nginx in zwei Varianten eingesetzt, die in zwei Unterverzeichnissen vorbereitet sind:

- `nginx-basic`: ein rudimentärer Reverse Proxy für den `whoami` Service.
- `nginx-secrets`: der gleiche Proxy, diesmal ergänzt um HTTPS und unter Verwendung des offiziellen Basis-Images.

Äquivalent zum `nginx-basic` gibt es eine Alternative, die [Træfik](https://traefik.io/) anstelle des Nginx' verwendet:

- `traefik`: enthält Træfik als dynamischer Reverse Proxy in einem Stack. 

## Lokale Testumgebung

Um lokal einen Swarm-Cluster einzurichten, eignen sich die Scripte im Verzeichnis `swarm`:

    ./01-init-swarm.sh
    ./02-init-worker.sh

Die beiden Befehle schalten zuerst die lokale Docker Engine in den Swarm Mode und richten dann
drei Worker ein. Darüber hinaus werden eine lokale Registry und ein Registry-Mirror gestartet.

Die Worker und Registries können per `./10-remove-worker.sh` wieder gestoppt werden. 

## Beispiele

_Disclaimer_: Die Beispiele sind stark an die offizielle Dokumentation unter [docs.docker.com](https://docs.docker.com/engine/swarm/configs/)
angelehnt.

### Nginx (basic)

Unter `nginx-basic` liegt eine Konfiguration für den Nginx als Reverse Proxy für
einen Beispiel-Service. Für ein manuelles Setup sind folgende Schritte notwendig:

    docker build -t 127.0.0.1:5000/nginx -f nginx-basic nginx-basic
    docker push 127.0.0.1:5000/nginx
    docker service create --detach=false --name basic --publish 8080:80 --replicas 3 127.0.0.1:5000/nginx

Das gleiche Setup ist etwas bequemer per Docker Stack möglich:

    docker stack deploy --compose-file nginx-basic/docker-stack.yml basic-stack

### Nginx (mit HTTPS)

Unter `nginx-secrets` liegt die gleiche Konfiguration aus [Nginx (basic)](#nginx-basic),
allerdings ergänzt um HTTPS Unterstützung unter Verwendung von Docker Secrets und Docker Configs.
Das manuelle Setup lautet wie folgt:

    nginx-secrets/gen-certs.sh
    docker secret create --name site.key nginx-secrets/cert/site.key
    docker secret create --name site.crt nginx-secrets/cert/site.crt
    docker config create --name https.conf nginx-secrets/backend-https.conf
    docker service create --detach=false --name https-proxy --publish 8443:443 --secret site.key --secret site.crt --config source=https.conf,target=/etc/nginx/conf.d/https.conf --replicas 3 nginx:alpine

Das gleiche Setup ist wieder etwas bequemer per Docker Stack möglich:

    docker stack deploy --compose-file nginx-secrets/docker-stack.yml https-stack

### Træfik (basic)

Unter `traefik` liegt ein Beispiel für die Verwendung von Træfik in einem Docker Swarm.
Das Beispiel kann per `docker stack` deployed werden:

    docker stack deploy --compose-file traefik/docker-stack.yml traefik

## Contributing

Fehlerkorrekturen oder Verbesserungen können gerne per Issue oder Pull Request eingereicht werden.
Die Beispiele sollten allerdings noch zum Inhalt des Artikels passen. Für Fragen stehe ich darüber
hinaus auf Twitter [@gesellix](https://twitter.com/gesellix) zur Verfügung.
