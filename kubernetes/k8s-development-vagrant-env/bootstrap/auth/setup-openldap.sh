#!/bin/bash

source /etc/environment

sudo -E -s <<"EOF"

# modify the slapd apparmor profile
cat >> /etc/apparmor.d/local/usr.sbin.slapd <<EOL
${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem r,
${CFSSL_TLS_GUEST_FOLDER}/auth/openldap-key.pem r,
${CFSSL_TLS_GUEST_FOLDER}/auth/openldap.pem r,
EOL

# reload the slapd apparmor profile
apparmor_parser -r /etc/apparmor.d/usr.sbin.slapd

# create openldap tls configuration file
cat > /var/lib/openldap/tlsconfig.ldif <<"EOL"
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: ${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem
-
add: olcTLSCertificateFile
olcTLSCertificateFile: ${CFSSL_TLS_GUEST_FOLDER}/auth/openldap.pem
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: ${CFSSL_TLS_GUEST_FOLDER}/auth/openldap-key.pem
EOL

# apply the ldap config
ldapmodify -H ldapi:// -Y EXTERNAL -f /var/lib/openldap/tlsconfig.ldif -v

# restart the ldap service
service slapd force-reload

#systemctl daemon-reload && systemctl enable slapd.service && systemctl start slapd.service

EOF

echo "OpenLDAP server v${OPENLDAP_VERSION} configured successfully"

exit 0
