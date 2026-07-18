{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  gawk,
  gnugrep,
  gnused,
  iproute2,
  iptables-legacy,
  libmnl,
  libnftnl,
  libuuid,
  linuxHeaders,
  makeWrapper,
  nftables,
  nixosTests,
  openssl,
  pkg-config,
  which,
  firewall ? "iptables",
}:

let
  scriptBinEnv =
    lib.makeBinPath
      {
        iptables = [
          # needed for dirname in ip{,6}tables_*.sh
          coreutils
          # used in miniupnpd_functions.sh:
          which
          iproute2
          iptables-legacy
          gnused
          gnugrep
          gawk
        ];

        nftables = [
          # needed for dirname in nft_*.sh & cat in nft_init.sh
          coreutils
          # used in miniupnpd_functions.sh:
          which
          nftables
        ];
      }
      .${firewall};
in
stdenv.mkDerivation rec {
  pname = "miniupnpd";
  version = "2.3.9";

  src = fetchurl {
    url = "https://miniupnp.tuxfamily.org/files/miniupnpd-${version}.tar.gz";
    sha256 = "sha256-Zss8PWl6srs6YdPEhigWbWujKNfC2+uViY/fKjICr3s=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    iptables-legacy
    libuuid
    openssl
  ]
  ++ lib.optionals (firewall == "nftables") [
    libmnl
    libnftnl
  ];

  configureFlags = [
    "--host-os=${stdenv.hostPlatform.uname.system}"
    "--host-os-version=${linuxHeaders.version}"
    "--host-machine=${stdenv.hostPlatform.uname.processor}"
    "--firewall=${firewall}"
    # allow using various config options
    "--ipv6"
    "--igd2"
    "--leasefile"
    "--regex"
    "--vendorcfg"
    # hardening
    "--portinuse"
  ];

  postFixup =
    {
      # Ideally we'd prefer using system's config.firewall.package here for iptables,
      # however for some reason switching --prefix to --suffix breaks the script
      iptables = ''
        for script in $out/etc/miniupnpd/ip{,6}tables_{init,removeall}.sh
        do
          wrapProgram $script --prefix PATH : '${scriptBinEnv}:$PATH'
        done
      '';

      nftables = ''
        for script in $out/etc/miniupnpd/nft_{delete_chain,flush,init,removeall}.sh
        do
          wrapProgram $script --suffix PATH : '${scriptBinEnv}:$PATH'
        done
      '';
    }
    .${firewall};

  # Similar for cross flags --host/--build
  configurePlatforms = [ ];
  # ./configure is not a standard configure file, errors with:
  # Option not recognized : --prefix=
  dontAddPrefix = true;

  installFlags = [
    "PREFIX=$(out)"
    "INSTALLPREFIX=$(out)"
  ];

  passthru.tests = {
    inherit (nixosTests) upnp;
    bittorrent-integration = nixosTests.bittorrent;
  };

  meta = {
    description = "Daemon that implements the UPnP Internet Gateway Device (IGD) specification";
    homepage = "https://miniupnp.tuxfamily.org/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "miniupnpd";
  };
}
