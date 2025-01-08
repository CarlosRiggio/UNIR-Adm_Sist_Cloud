MONGO_VERSION=6.0

sudo apt-get update
sudo apt-get install gnupg

# import MongoDB GPG public key
wget -qO - https://www.mongodb.org/static/pgp/server-${MONGO_VERSION}.asc | sudo apt-key add -
sudo cd /etc/apt/sources.list.d/
sudo touch mongodb-org-${MONGO_VERSION}.list
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${MONGO_VERSION} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown mongodb:mongodb /tmp/mongodb-27017.sock
sudo service mongod start
sudo systemctl status mongod