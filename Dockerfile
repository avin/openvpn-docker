FROM phusion/baseimage:0.9.17
MAINTAINER Avin Grape <carcinogen75@gmail.com>

# Locale configuration
ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Installation
RUN apt-get update -y
RUN apt-get install openvpn easy-rsa iptables -y


# Openvpn server configuration
RUN gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf
RUN sed -i -e 's/dh dh1024.pem/dh dh2048.pem/' /etc/openvpn/server.conf
RUN sed -i -e 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/' /etc/openvpn/server.conf
RUN sed -i -e 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/' /etc/openvpn/server.conf
RUN sed -i -e 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 208.67.220.220"/' /etc/openvpn/server.conf
RUN sed -i -e 's/;user nobody/user nobody/' /etc/openvpn/server.conf
RUN sed -i -e 's/;group nogroup/group nogroup/' /etc/openvpn/server.conf

# Creating a Certificate Authority and Server-Side Certificate & Key
RUN cp -r /usr/share/easy-rsa/ /etc/openvpn
RUN mkdir -p /etc/openvpn/easy-rsa/keys
RUN echo 'export KEY_NAME="server"' >> /etc/openvpn/easy-rsa/vars
RUN openssl dhparam -out /etc/openvpn/dh2048.pem 2048
WORKDIR /etc/openvpn/easy-rsa
RUN . ./vars && ./clean-all && ./build-ca --batch && ./build-key-server --batch server
RUN cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn
RUN cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn
RUN cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn

# Create a `openvpn` `runit` service
ADD openvpn /etc/sv/openvpn
RUN update-service --add /etc/sv/openvpn

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose the openssh ports
EXPOSE 1194/udp

# Add the README
ADD README.md /usr/local/share/doc/

# Add the help file
RUN mkdir -p /usr/local/share/doc/run
ADD help.txt /usr/local/share/doc/run/help.txt

# Add the entrypoint
ADD run.sh /usr/local/sbin/run
ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/sbin/run"]

# Default to showing the usage text
CMD ["help"]
