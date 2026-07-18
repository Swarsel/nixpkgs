{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  curl,
  iksemel,
  libevent,
  libiconv,
  libmysqlclient,
  libpq,
  libssh2,
  libxml2,
  net-snmp,
  openipmi,
  openldap,
  openssl,
  pcre2,
  pkg-config,
  unixodbc,
  zlib,
  ipmiSupport ? false,
  jabberSupport ? true,
  ldapSupport ? true,
  mysqlSupport ? false,
  odbcSupport ? true,
  postgresqlSupport ? false,
  snmpSupport ? true,
  sshSupport ? true,
}:

# ensure exactly one primary database type is selected
assert mysqlSupport -> !postgresqlSupport;
assert postgresqlSupport -> !mysqlSupport;

let
  inherit (lib) optional optionalString;
in
import ./versions.nix (
  { hash, version, ... }:
  stdenv.mkDerivation {
    inherit version;
    pname = "zabbix-server";

    src = fetchurl {
      inherit hash;
      url = "https://cdn.zabbix.com/zabbix/sources/stable/${lib.versions.majorMinor version}/zabbix-${version}.tar.gz";
    };

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
    ]
    ++ optional postgresqlSupport libpq.pg_config;

    buildInputs = [
      curl
      libevent
      libiconv
      libxml2
      openssl
      pcre2
      zlib
    ]
    ++ optional odbcSupport unixodbc
    ++ optional jabberSupport iksemel
    ++ optional ldapSupport openldap
    ++ optional snmpSupport net-snmp
    ++ optional sshSupport libssh2
    ++ optional mysqlSupport libmysqlclient
    ++ optional postgresqlSupport libpq
    ++ optional ipmiSupport openipmi;

    configureFlags = [
      "--enable-ipv6"
      "--enable-server"
      "--with-iconv"
      "--with-libcurl"
      "--with-libevent"
      "--with-libpcre2"
      "--with-libxml2"
      "--with-openssl=${openssl.dev}"
      "--with-zlib=${zlib}"
    ]
    ++ optional odbcSupport "--with-unixodbc"
    ++ optional jabberSupport "--with-jabber"
    ++ optional ldapSupport "--with-ldap=${openldap.dev}"
    ++ optional snmpSupport "--with-net-snmp"
    ++ optional sshSupport "--with-ssh2=${libssh2.dev}"
    ++ optional mysqlSupport "--with-mysql"
    ++ optional postgresqlSupport "--with-postgresql"
    ++ optional ipmiSupport "--with-openipmi=${openipmi.dev}";

    postInstall = ''
      mkdir -p $out/share/zabbix/database/
      cp -r include $out/
    ''
    + optionalString mysqlSupport ''
      mkdir -p $out/share/zabbix/database/mysql
      cp -prvd database/mysql/*.sql $out/share/zabbix/database/mysql/
    ''
    + optionalString postgresqlSupport ''
      mkdir -p $out/share/zabbix/database/postgresql
      cp -prvd database/postgresql/*.sql $out/share/zabbix/database/postgresql/

      mkdir -p $out/share/zabbix/database/postgresql/timescaledb
      cp -prvd database/postgresql/timescaledb/schema.sql $out/share/zabbix/database/postgresql/timescaledb/schema.sql
    '';

    enableParallelBuilding = true;

    preAutoreconf = ''
      for i in $(find . -type f -name "*.m4"); do
        substituteInPlace $i \
          --replace 'test -x "$PKG_CONFIG"' 'type -P "$PKG_CONFIG" >/dev/null'
      done
    '';

    prePatch = ''
      find database -name data.sql -exec sed -i 's|/usr/bin/||g' {} +
    '';

    meta = {
      description = "Enterprise-class open source distributed monitoring solution";
      homepage = "https://www.zabbix.com/";

      license =
        if (lib.versions.major version >= "7") then lib.licenses.agpl3Only else lib.licenses.gpl2Plus;

      maintainers = with lib.maintainers; [
        bstanderline
        mmahut
        psyanticy
      ];

      platforms = lib.platforms.linux;
    };
  }
)
