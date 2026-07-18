{
  lib,
  stdenv,
  fetchurl,
  libiconv,
  openssl,
  pcre2,
  pkg-config,
}:

import ./versions.nix (
  { hash, version, ... }:
  stdenv.mkDerivation {
    inherit version;
    pname = "zabbix-agent";

    src = fetchurl {
      inherit hash;
      url = "https://cdn.zabbix.com/zabbix/sources/stable/${lib.versions.majorMinor version}/zabbix-${version}.tar.gz";
    };

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      libiconv
      openssl
      pcre2
    ];

    configureFlags = [
      "--enable-agent"
      "--enable-ipv6"
      "--with-iconv"
      "--with-libpcre2"
      "--with-openssl=${openssl.dev}"
    ];

    makeFlags = [
      "AR:=$(AR)"
      "RANLIB:=$(RANLIB)"
    ];

    postInstall = ''
      cp conf/zabbix_agentd/*.conf $out/etc/zabbix_agentd.conf.d/
    '';

    enableParallelBuilding = true;

    meta = {
      description = "Enterprise-class open source distributed monitoring solution (client-side agent)";
      homepage = "https://www.zabbix.com/";

      license =
        if (lib.versions.major version >= "7") then lib.licenses.agpl3Only else lib.licenses.gpl2Plus;

      maintainers = with lib.maintainers; [
        bstanderline
        mmahut
        psyanticy
      ];

      platforms = lib.platforms.unix;
    };
  }
)
