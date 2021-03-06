FROM debian:jessie

MAINTAINER Fidor Solutions <connect@fidor.com>

ENV OPENLDAP_VERSION 2.4.40
ENV SLAPD_PASSWORD rootroot
ENV SLAPD_DOMAIN fidor.loc 
ENV SLAPD_ADDITIONAL_MODULES memberof
RUN mkdir -p /etc/ldap/prepopulate
COPY 1.baseorg.ldif /etc/ldap/prepopulate/
COPY 2.users.ldif /etc/ldap/prepopulate/
COPY 3.groups.ldif /etc/ldap/prepopulate/
COPY 4.grouppopulate.ldif /etc/ldap/prepopulate/
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        slapd=${OPENLDAP_VERSION}* ldap-utils ldapscripts && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mv /etc/ldap /etc/ldap.dist

COPY modules/ /etc/ldap.dist/modules

COPY entrypoint.sh /entrypoint.sh

EXPOSE 389


VOLUME ["/etc/ldap", "/var/lib/ldap"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["slapd", "-d", "-1", "-u", "openldap", "-g", "openldap"]
