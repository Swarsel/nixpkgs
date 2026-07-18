{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cargo,
  cracklib,
  cyrus_sasl,
  db,
  fetchpatch,
  icu,
  json_c,
  krb5,
  libevent,
  libtool,
  libxcrypt,
  linux-pam,
  lmdb,
  net-snmp,
  nix-update-script,
  nspr,
  nss,
  openldap,
  openssl,
  pcre2,
  pkg-config,
  python3,
  rsync,
  rustPlatform,
  rustc,
  systemd,
  zlib,
  withAsan ? false,
  withBdb ? true,
  withCockpit ? true,
  withNetSnmp ? true,
  withOpenldap ? true,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "389-ds-base";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "389ds";
    repo = "389-ds-base";
    rev = "389-ds-base-${finalAttrs.version}";
    hash = "sha256-hRTK9xBu8v8+SGa/3IB8Alh/aGUiRRn2LmYOvXy0Yd4=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-trzY/fDH3rs66DWbWI+PY46tIC9ShuVqspMHqEEKZYA=";
      # https://github.com/389ds/389-ds-base/pull/6930
      name = "389-ds-base-rustc-1_89.patch";
      url = "https://github.com/389ds/389-ds-base/commit/1701419551c246e9dc21778b118220eeb2258125.patch";
    })
    ./0001-remove-hard-coded-vendor-paths.patch
    (fetchpatch {
      hash = "sha256-ItxG0bnuNPWLClL677rChTDvDWXxJ2L6ygx4VY2v80w=";
      # https://github.com/389ds/389-ds-base/security/advisories/GHSA-4qwg-c5j2-q4hp
      name = "CVE-2025-14905.patch";
      url = "https://github.com/389ds/389-ds-base/commit/2e424110def2e3998f6045e136fb0d43f47b7f5a.patch";
    })
  ];

  postPatch = ''
    patchShebangs ./buildnum.py ./ldap/servers/slapd/mkDBErrStrs.py
  '';

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    python3
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ]
  ++ lib.optional withCockpit rsync;

  buildInputs = [
    cracklib
    lmdb
    json_c
    linux-pam
    libevent
    libxcrypt
    nspr
    nss
    cyrus_sasl
    icu
    krb5
    pcre2
    openssl
    zlib
  ]
  ++ lib.optional withSystemd systemd
  ++ lib.optional withOpenldap openldap
  ++ lib.optional withBdb db
  ++ lib.optional withNetSnmp net-snmp;

  configureFlags = [
    "--enable-rust-offline"
    "--enable-autobind"
  ]
  ++ lib.optionals withSystemd [
    "--with-systemd"
    "--with-systemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
  ]
  ++ lib.optionals withOpenldap [
    "--with-openldap"
  ]
  ++ lib.optionals withBdb [
    "--with-db-inc=${lib.getDev db}/include"
    "--with-db-lib=${lib.getLib db}/lib"
  ]
  ++ lib.optionals withNetSnmp [
    "--with-netsnmp-inc=${lib.getDev net-snmp}/include"
    "--with-netsnmp-lib=${lib.getLib net-snmp}/lib"
  ]
  ++ lib.optionals (!withCockpit) [
    "--disable-cockpit"
  ]
  ++ lib.optionals withAsan [
    "--enable-asan"
    "--enable-debug"
  ];

  preConfigure = ''
    ./autogen.sh --prefix="$out"
  '';

  doCheck = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src cargoRoot;
    hash = "sha256-pNzMQjeBpmzFg6oWCxhLDmKGUKIW6jGmZQWai5Yunjc=";
    name = "389-ds-base-${finalAttrs.version}";
  };

  cargoRoot = "src";
  enableParallelBuilding = true;
  # Disable parallel builds as those lack some dependencies:
  #   ld: cannot find -lslapd: No such file or directory
  # https://hydra.nixos.org/log/h38bj77gav0r6jbi4bgzy1lfjq22k2wy-389-ds-base-2.3.1.drv
  enableParallelInstalling = false;

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "localstatedir=${placeholder "TMPDIR"}"
  ];

  passthru.updateScript = nix-update-script { };
  passthru.version = finalAttrs.version;

  meta = {
    description = "Enterprise-class Open Source LDAP server for Linux";
    homepage = "https://www.port389.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.ners ];
    platforms = lib.platforms.linux;
  };
})
