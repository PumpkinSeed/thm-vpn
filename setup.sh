#!/bin/sh

##################
# Install docker #
##################

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' |
sudo tee /etc/apt/sources.list.d/docker.list

apt update
apt install docker-ce -y

systemctl start docker


###################
# Install openvpn #
###################

apt install -y git

git clone https://github.com/kylemanna/docker-openvpn.git
cd docker-openvpn/
docker build -t myownvpn .
cd ..
mkdir vpn-data && touch vpn-data/vars

docker run -v $PWD/vpn-data:/etc/openvpn --rm myownvpn ovpn_genconfig -u udp://$1:3000

docker run -v $PWD/vpn-data:/etc/openvpn --rm -it myownvpn ovpn_initpki

docker run -v $PWD/vpn-data:/etc/openvpn -d -p 3000:1194/udp --cap-add=NET_ADMIN myownvpn


docker run -v $PWD/vpn-data:/etc/openvpn --rm -it myownvpn easyrsa build-client-full user1 nopass
docker run -v $PWD/vpn-data:/etc/openvpn --rm myownvpn ovpn_getclient user1 > user1.ovpn

docker run -v $PWD/vpn-data:/etc/openvpn --rm -it myownvpn easyrsa build-client-full user2 nopass
docker run -v $PWD/vpn-data:/etc/openvpn --rm myownvpn ovpn_getclient user1 > user2.ovpn

docker run -v $PWD/vpn-data:/etc/openvpn --rm -it myownvpn easyrsa build-client-full user3 nopass
docker run -v $PWD/vpn-data:/etc/openvpn --rm myownvpn ovpn_getclient user1 > user3.ovpn

