{
  lib,
  fetchurl,
  autoreconfHook,
  buildGoModule,
  libiconv,
  openssl,
  pcre2,
  pkg-config,
  zlib,
}:

import ./versions.nix (
  {
    hash,
    version,
    ...
  }:
  buildGoModule {
    inherit version;
    pname = "zabbix-agent2";

    src = fetchurl {
      inherit hash;
      url = "https://cdn.zabbix.com/zabbix/sources/stable/${lib.versions.majorMinor version}/zabbix-${version}.tar.gz";
    };

    # need to provide GO* env variables & patch for reproducibility
    postPatch = ''
      substituteInPlace src/go/Makefile.am \
        --replace '`go env GOOS`' "$GOOS" \
        --replace '`go env GOARCH`' "$GOARCH" \
        --replace '`date +%H:%M:%S`' "00:00:00" \
        --replace '`date +"%b %_d %Y"`' "Jan 1 1970"
    '';

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
    ];

    buildInputs = [
      libiconv
      openssl
      pcre2
      zlib
    ];

    vendorHash = null;

    # manually configure the c dependencies
    preConfigure = ''
      ./configure \
        --prefix=${placeholder "out"} \
        --enable-agent2 \
        --enable-ipv6 \
        --with-iconv \
        --with-libpcre2 \
        --with-openssl=${openssl.dev}
    '';

    # zabbix build process is complex to get right in nix...
    # use automake to build the go project ensuring proper access to the go vendor directory
    buildPhase = ''
      cd ../..
      make
    '';

    installPhase = ''
      mkdir -p $out/sbin

      install -Dm0644 src/go/conf/zabbix_agent2.conf $out/etc/zabbix_agent2.conf
      install -Dm0755 src/go/bin/zabbix_agent2 $out/bin/zabbix_agent2

      # create a symlink which is compatible with the zabbixAgent module
      ln -s $out/bin/zabbix_agent2 $out/sbin/zabbix_agentd
    '';

    modRoot = "src/go";

    meta = {
      description = "Enterprise-class open source distributed monitoring solution (client-side agent)";
      homepage = "https://www.zabbix.com/";

      license =
        if (lib.versions.major version >= "7") then lib.licenses.agpl3Only else lib.licenses.gpl2Plus;

      maintainers = with lib.maintainers; [
        aanderse
        bstanderline
      ];

      platforms = lib.platforms.unix;
    };
  }
)
