
# Check if running as root 
if [[ $UID  != 0 || $USER != "root" ]]; then
    echo "Run it as root!"
    exit
fi 

##### Set these values to whatever u want #####
NEW_USER=user1 
CLIENT_NAME=client1
SERVER_NAME=server
IP_SUBNET=10.10.10.0
SUBNET_MASK=255.255.255.0
########################################

# Step 1 - update everything & enable auto updates.
apt update -y 
apt upgrade -y 

if ! command unattended-upgrade 2>&1 >/dev/null 
then 
    echo "Installing unattended upgrade"
    apt install unattended-upgrades -y 
fi

dpkg-reconfigure unattended-upgrades

# Step 2 - download some additional binaries 
packages=("wget" "openvpn" "easy-rsa" "fail2ban" "iptables" "sshd")
for pkg in ${packages[@]}; do
    
    if ! command $pkg 2>&1 >/dev/null 
    then 
        apt install $pkg -y 
    fi

done

# Setup openvpn 
cd /usr/share/easy-rsa
./easyrsa init-pki
./easyrsa build-ca              # /usr/share/easy-rsa/pki/ca.crt
cd pki
../easyrsa build-server-full $SERVER_NAME    # /usr/share/easy-rsa/pki/server.crt
cd ..
easyrsa build-client-full $CLIENT_NAME   
./easyrsa gen-dh

openvpn --genkey tls-auth ta.key
useradd openvpn 




# Create openssh file

# find /var/log/* -maxdepth 1 -type f 2>&/dev/null
# iptables -I INPUT -p icmp --icmp-type echo-request -j DROP