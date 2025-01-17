#!/bin/bash

set -e

logger "Arrancando instalacion y configuracion de MongoDB"
USO="Uso : install.sh [opciones]
Ejemplo:
install.sh -f archivo_configuracion [-a]
Opciones:
-f archivo de configuración
-a muestra esta ayuda
"
function ayuda() {
  echo "${USO}"
  if [[ ${1} ]]; then
    echo ${1}
  fi
}

# Gestionar los argumentos de la línea de comandos
while getopts ":f:a" OPCION; do
  case ${OPCION} in
    f) CONFIG_FILE=$OPTARG ;;  
    a) ayuda; exit 0 ;;  
    \?) ayuda "La opción no existe : $OPTARG"; exit 1 ;;
  esac
done

if [ -z ${CONFIG_FILE} ]; then
  ayuda "Debe especificarse el archivo de configuración con -f"; exit 1
fi


source ${CONFIG_FILE}

if [ -z ${user} ]; then
  ayuda "El usuario (-u) debe ser especificado en el archivo de configuración"; exit 1
fi

if [ -z ${password} ]; then
  ayuda "La contraseña (-p) debe ser especificada en el archivo de configuración"; exit 1
fi

if [ -z ${port} ]; then
  port=27017  
fi


echo "Configuración cargada desde el archivo ${CONFIG_FILE}:"
echo "Usuario: ${user}"
echo "Contraseña: ${password}"
echo "Puerto: ${port}"


apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb.list


if [[ -z "$(mongo --version 2> /dev/null | grep '4.2.1')" ]]; then
  apt-get -y update \
  && apt-get install -y \
  mongodb-org=4.2.1 \
  mongodb-org-server=4.2.1 \
  mongodb-org-shell=4.2.1 \
  mongodb-org-mongos=4.2.1 \
  mongodb-org-tools=4.2.1 \
  && rm -rf /var/lib/apt/lists/* \
  && pkill -u mongodb || true \
  && pkill -f mongod || true \
  && rm -rf /var/lib/mongodb
fi


[[ -d "/datos/bd" ]] || mkdir -p -m 755 "/datos/bd"
[[ -d "/datos/log" ]] || mkdir -p -m 755 "/datos/log"


chown mongodb /datos/log /datos/bd
chgrp mongodb /datos/log /datos/bd


mv /etc/mongod.conf /etc/mongod.conf.orig
(
cat <<MONGOD_CONF
# /etc/mongod.conf
systemLog:
   destination: file
   path: /datos/log/mongod.log
   logAppend: true
storage:
   dbPath: /datos/bd
   engine: wiredTiger
   journal:
      enabled: true
net:
   port: ${port}
security:
   authorization: enabled
MONGOD_CONF
) > /etc/mongod.conf

systemctl restart mongod

echo "Esperando a que MongoDB esté listo..."
until mongo --eval "print('MongoDB se está ejecutando')" > /dev/null 2>&1; do
  echo "Esperando..."
  sleep 1
done

mongo admin << CREACION_DE_USUARIO
db.createUser({
    user: "${user}",
    pwd: "${password}",
    roles:[{
        role: "root",
        db: "admin"
    },{
        role: "restore",
        db: "admin"
    }]
})
CREACION_DE_USUARIO

logger "El usuario ${user} ha sido creado con éxito!"

exit 0
