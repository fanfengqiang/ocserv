FROM centos:7

RUN yum install wget -y \
    && yum -y install kde-l10n-Chinese && yum -y reinstall glibc-common \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && rm -rf /etc/yum.repos.d/* \
    && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo \
    && yum clean all \
    && yum install -y ocserv-0.12.3-1.el7 less net-tools iproute iptables bash-completion vim gcc gcc-c++ \
    && yum clean all && rm -rf /var/cache/yum \
    && wget https://fossies.org/linux/misc/freeradius-client-1.1.7.tar.gz \
    && tar -zxf freeradius-client-1.1.7.tar.gz \
    && cd freeradius-client-1.1.7 \
    && ./configure \
    && make && make install \
    && cd .. && rm -rf freeradius-client-1.1.7*

ENV LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

ENV INTERFACE="eth0" \
    MAXSAMECLIENTS=2 \
    MAXCLIENTS=1024 \
    VPNNETWORK="172.32.128.0/21" \
    DNS1="114.114.114.114" \
    DNS2="8.8.8.8" \
    OCSSERVCONFIG="/etc/ocserv" \
    PORT="443" \
    SECRET=testing123 \
    RX_SPEED=1024000 \
    TX_SPEED=1024000

ADD start.sh /start.sh

RUN sed -i "s@testing123@${SECRET}@" /usr/local/etc/radiusclient/servers \
    && sed -i 's@#localhost/localhost@localhost/localhost@' /usr/local/etc/radiusclient/servers \
    && sed -i 's@auth = "pam"@#auth = "pam"\nauth = "radius[config=/usr/local/etc/radiusclient/radiusclient.conf,groupconfig=true]"@g' "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i 's@#acct = .*@acct = "radius[config=/usr/local/etc/radiusclient/radiusclient.conf,groupconfig=true]"@' "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/max-same-clients = 2/max-same-clients = ${MAXSAMECLIENTS}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/max-clients = 16/max-clients = ${MAXCLIENTS}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/tcp-port = 443/tcp-port = ${PORT}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/udp-port = 443/udp-port = ${PORT}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i 's/^ca-cert = /#ca-cert = /g' "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i 's/^cert-user-oid = /#cert-user-oid = /g' "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/default-domain = example.com/#default-domain = example.com/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s@#ipv4-network = 192.168.1.0/24@ipv4-network = ${VPNNETWORK}@g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/#dns = 192.168.1.2/dns = ${DNS1}\ndns = ${DNS2}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/#rx-data-per-sec = 40000/rx-data-per-sec = ${RX_SPEED}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/#tx-data-per-sec = 40000/tx-data-per-sec = ${TX_SPEED}/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i "s/cookie-timeout = 300/cookie-timeout = 86400/g" "${OCSSERVCONFIG}/ocserv.conf" \
    && sed -i 's/user-profile = profile.xml/#user-profile = profile.xml/g' "${OCSSERVCONFIG}/ocserv.conf" \
    && chmod +x /start.sh

CMD /start.sh
