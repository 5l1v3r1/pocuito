#!/usr/bin/env sh

RootDir=$1

certs_folder="certs"
ca_cert="ca.crt"
ca_key="ca.key"
ca_pass_file="ca_pass.txt"
ca_key_pass=$(head /dev/random -c16 | od -tx1 -w16 | head -n1 | cut -d' ' -f2- | tr -d ' ')

if [ ! -f ${ca_cert} ]; then

    # If ca.crt is absent then all the old signed certs have to be wiped clean first
    if [ -d ${certs_folder} ]; then
        rm -r ${certs_folder}
    fi
    mkdir -p ${certs_folder}

    # A file is created which consists of CA password
    if [ -f ${ca_pass_file} ]; then
        rm ${ca_pass_file}
    fi
    echo $ca_key_pass >> $ca_pass_file
    openssl genrsa -des3 -passout pass:${ca_key_pass} -out "$ca_key" 4096
    openssl req -new -x509 -days 3650 -subj "/C=US/ST=Pwnland/L=OWASP/O=OWTF/CN=MiTMProxy" -passin pass:${ca_key_pass} -key "$ca_key" -out "$ca_cert"
    echo "[!] Don't forget to add the $ca_cert as a trusted CA in your browser"
fi
