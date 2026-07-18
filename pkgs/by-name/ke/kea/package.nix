{
  lib,
  stdenv,
  fetchurl,
  # build time
  bison,
  # runtime
  boost,
  flex,
  kea,
  krb5,
  libmysqlclient,
  libpq,
  log4cplus,
  meson,
  ninja,
  # tests
  nixosTests,
  openssl,
  pkg-config,
  python3,
  python3Packages,
  testers,
  withKrb5 ? true,
  withMysql ? stdenv.buildPlatform.system == stdenv.hostPlatform.system,
  withPostgresql ? stdenv.buildPlatform.system == stdenv.hostPlatform.system,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kea";
  version = "3.2.0"; # only even minor versions are stable

  src = fetchurl {
    url = "https://ftp.isc.org/isc/kea/${finalAttrs.version}/kea-${finalAttrs.version}.tar.xz";
    hash = "sha256-FL9pXTe2W5sb9VD+pdCtr5gGxQ5UGe8qF2pLjpqt498=";
  };

  outputs = [
    "out"
    "doc"
    "python"
  ];

  patches = [
    ./dont-create-system-paths.patch
  ];

  postPatch = ''
    patchShebangs \
      scripts/grabber.py \
      doc/sphinx/*.sh.in
  '';

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
    pkg-config
    python3
  ]
  ++ (with python3Packages; [
    sphinx
    sphinx-rtd-theme
  ]);

  buildInputs = [
    boost
    log4cplus
    openssl
    python3
  ]
  ++ lib.optionals withMysql [
    libmysqlclient
  ]
  ++ lib.optionals withPostgresql [
    libpq
  ]
  ++ lib.optionals withKrb5 [
    krb5
  ];

  mesonFlags = [
    (lib.mesonOption "crypto" "openssl")
    (lib.mesonEnable "krb5" withKrb5)
    (lib.mesonEnable "mysql" withMysql)
    (lib.mesonEnable "netconf" false) # missing libyang-cpp, sysinfo, libsysrepo-cpp
    (lib.mesonEnable "postgresql" withPostgresql)
    (lib.mesonOption "localstatedir" "/var")
    (lib.mesonOption "runstatedir" "/run")
    (lib.mesonOption "python.platlibdir" "${placeholder "python"}/${python3.sitePackages}")
    (lib.mesonOption "python.purelibdir" "${placeholder "python"}/${python3.sitePackages}")
  ];

  postConfigure = ''
    # Mangle embedded paths to dev-only inputs.
    for file in config.report meson-info/intro*.json; do
      sed -e "s|$NIX_STORE/[a-z0-9]\{32\}-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" -i "$file"
    done
  '';

  postBuild = ''
    ninja doc
  '';

  passthru.tests = {
    version = testers.testVersion {
      version = finalAttrs.version;
      command = "kea-shell -v";
      package = kea;
    };

    kea = nixosTests.kea;

    networking-networkd = lib.recurseIntoAttrs {
      inherit (nixosTests.networking.networkd) dhcpDefault dhcpSimple dhcpOneIf;
    };

    networking-scripted = lib.recurseIntoAttrs {
      inherit (nixosTests.networking.scripted) dhcpDefault dhcpSimple dhcpOneIf;
    };

    prefix-delegation = nixosTests.systemd-networkd-ipv6-prefix-delegation;
  };

  meta = {
    description = "High-performance, extensible DHCP server by ISC";

    longDescription = ''
      Kea is a new open source DHCPv4/DHCPv6 server being developed by
      Internet Systems Consortium. The objective of this project is to
      provide a very high-performance, extensible DHCP server engine for
      use by enterprises and service providers, either as is or with
      extensions and modifications.
    '';

    homepage = "https://kea.isc.org/";
    changelog = "https://gitlab.isc.org/isc-projects/kea/-/wikis/Release-Notes/release-notes-${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      fpletz
      hexa
    ];

    platforms = lib.platforms.unix;
    # error: in-class initializer for static data member is not a constant expression
    broken = stdenv.hostPlatform.isDarwin;
  };
})
