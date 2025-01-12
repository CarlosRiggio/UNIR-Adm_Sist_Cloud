#!/bin/bash
set -e
logger "Arrancando instalación y configuración de MongoDB"

USO="Uso: install.sh -f config.ini
Opciones:
-f archivo de configuración (config.ini)
-a muestra esta ayuda
"

function ayuda() {
    echo "${USO}"
    if [[ ${1} ]]; then
        echo ${1}
    fi
}

# Gestionar los argumentos
while getopts ":f:a" OPCION; do
    case ${OPCION} in
        f ) CONFIG_FILE=$OPTARG
            echo "Archivo de configuración especificado como '${CONFIG_FILE}'";;
        a ) ayuda; exit 0;;
        : ) ayuda "Falta el parametro para -$OPTARG"; exit 1;;
        \?) ayuda "La opción no existe : $OPTARG"; exit 1;;
    esac
done

if [ -z ${CONFIG_FILE} ]; then
    ayuda "El archivo de configuración (-f) debe ser especificado"; exit 1
fi

# Leer el archivo de configuración
source ${CONFIG_FILE}

if [ -z ${user} ]; then
    ayuda "El parámetro user debe estar especificado en el archivo de configuración"; exit 1
fi

if [ -z ${password} ]; then
    ayuda "El parámetro password debe estar especificado en el archivo de configuración"; exit 1
fi

if [ -z ${port} ]; then
    port=27017
fi

# Añadir clave GPG y configurar el repositorio de MongoDB
logger "Añadiendo clave GPG y configurando el repositorio de MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-6.0.gpg
echo "deb [ arch=amd64,signed-by=/usr/share/keyrings/mongodb-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Actualizar la lista de paquetes
logger "Actualizando lista de paquetes..."
sudo apt-get update

# Instalar MongoDB si no está instalado
if [[ -z "$(mongo --version 2> /dev/null | grep '6.0')" ]]; then
    logger "Instalando MongoDB..."
    sudo apt-get install -y mongodb-org
fi

# Crear las carpetas de logs y datos con sus permisos
logger "Configurando directorios de MongoDB..."
[[ -d "/datos/bd" ]] || mkdir -p -m 755 "/datos/bd"
[[ -d "/datos/log" ]] || mkdir -p -m 755 "/datos/log"

# Establecer el dueño y el grupo de las carpetas db y log
sudo chown mongodb /datos/log /datos/bd
sudo chgrp mongodb /datos/log /datos/bd

# Crear el archivo de configuración de mongodb con el puerto solicitado
logger "Creando archivo de configuración de MongoDB..."
sudo mv /etc/mongod.conf /etc/mongod.conf.orig
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
) | sudo tee /etc/mongod.conf

# Reiniciar el servicio de mongod para aplicar la nueva configuración
logger "Reiniciando el servicio de MongoDB..."
# Detener cualquier instancia previa de MongoDB
pkill -f mongod || true

# Iniciar MongoDB manualmente con la nueva configuración
mongod --config /etc/mongod.conf --fork

# Comprobar si MongoDB está corriendo correctamente
logger "Comprobando si mongod está activo..."
if systemctl is-active --quiet mongod; then
    logger "MongoDB está corriendo correctamente."
else
    logger "Hubo un problema al iniciar MongoDB."
    exit 1
fi

# Crear usuario con la password proporcionada como parámetro
logger "Creando usuario administrador en MongoDB..."
mongo admin << CREACION_DE_USUARIO
db.createUser({
    user: "${user}",
    pwd: "${password}",
    roles:[
        {
            role: "root",
            db: "admin"
        },
        {
            role: "restore",
            db: "admin"
        }
    ]
})
CREACION_DE_USUARIO

logger "El usuario ${user} ha sido creado con éxito!"
exit 0
