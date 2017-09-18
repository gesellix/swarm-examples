#!/usr/bin/env bash

set -o nounset
set -o errexit
#set -o xtrace

cd "${BASH_SOURCE%/*}"

openssl genrsa -out "cert/root-ca.key" 4096

openssl req -new -key "cert/root-ca.key" -out "cert/root-ca.csr" -sha256 -subj '/C=DE/ST=/L=/O=Examples/CN=Swarm Secret Example CA'

cat << EOF > cert/root-ca.cnf
[root_ca]
basicConstraints = critical,CA:TRUE,pathlen:1
keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
subjectKeyIdentifier=hash
EOF

openssl x509 -req -days 3650 -in "cert/root-ca.csr" -signkey "cert/root-ca.key" -sha256 -out "cert/root-ca.crt" -extfile "cert/root-ca.cnf" -extensions root_ca

openssl genrsa -out "cert/site.key" 4096

openssl req -new -key "cert/site.key" -out "cert/site.csr" -sha256 -subj '/C=DE/ST=/L=/O=Examples/CN=localhost'

cat << EOF > cert/site.cnf
[server]
authorityKeyIdentifier=keyid,issuer
basicConstraints = critical,CA:FALSE
extendedKeyUsage=serverAuth
keyUsage = critical, digitalSignature, keyEncipherment
subjectAltName = DNS:localhost, IP:127.0.0.1
subjectKeyIdentifier=hash
EOF

openssl x509 -req -days 750 -in "cert/site.csr" -sha256 -CA "cert/root-ca.crt" -CAkey "cert/root-ca.key" -CAcreateserial -out "cert/site.crt" -extfile "cert/site.cnf" -extensions server
