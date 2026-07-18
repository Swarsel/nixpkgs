{
  lib,
  stdenv,
  fetchFromGitHub,
  adcli,
  augeas,
  autoreconfHook,
  c-ares,
  check,
  cifs-utils,
  cmocka,
  curl,
  cyrus_sasl,
  dbus,
  ding-libs,
  dnsutils,
  docbook_xml_dtd_45,
  docbook_xsl,
  doxygen,
  fakeroot,
  glib,
  glibc,
  jansson,
  jose,
  keyutils,
  ldb,
  libcap,
  libkrb5,
  libnl,
  libunistring,
  libuuid,
  libxml2,
  libxslt,
  makeWrapper,
  ncurses,
  nfs-utils,
  nix-update-script,
  nixosTests,
  nspr,
  nss,
  nss_wrapper,
  openldap,
  p11-kit,
  pam,
  pcre2,
  perlPackages,
  pkg-config,
  popt,
  python3,
  samba,
  systemd,
  talloc,
  tdb,
  testers,
  tevent,
  uid_wrapper,
  versionCheckHook,
  withSudo ? false,
}:

let
  docbookFiles = "${docbook_xsl}/share/xml/docbook-xsl/catalog.xml:${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";
  # NOTE: freeipa and sssd need to be built with the same version of python
  inherit (perlPackages) Po4a;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sssd";
  version = "2.13.1";

  src = fetchFromGitHub {
    owner = "SSSD";
    repo = "sssd";
    tag = finalAttrs.version;
    hash = "sha256-f4abHqZ8ojNU4dVw1hkfEJC4asE/NamhYmOQyy368eI=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    # Keep in mind to check /src/external/pac_responder.m4 for Kerberos compatibility before update Kerberos !!!
    # Fix Kerberos Support version for PAC responder
    #./fix-kerberos-version.patch
  ];

  postPatch = ''
    patchShebangs ./sbus_generate.sh.in
  '';

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
    doxygen
  ];

  buildInputs = [
    augeas
    dnsutils
    c-ares
    curl
    cyrus_sasl
    ding-libs
    libcap
    libnl
    libunistring
    nss
    samba
    nfs-utils
    p11-kit
    (python3.withPackages (
      p: with p; [
        setuptools
        distutils
        python-ldap
      ]
    ))
    popt
    talloc
    tdb
    tevent
    ldb
    pam
    openldap
    pcre2
    libkrb5
    cifs-utils
    glib
    keyutils
    dbus
    fakeroot
    libxslt
    libxml2
    libuuid
    systemd
    nspr
    check
    cmocka
    uid_wrapper
    nss_wrapper
    ncurses
    Po4a
    jansson
    jose
  ];

  makeFlags = [
    "SGML_CATALOG_FILES=${docbookFiles}"
  ];

  # Something is looking for <libxml/foo.h> instead of <libxml2/libxml/foo.h>
  env.NIX_CFLAGS_COMPILE = toString [
    "-DRENEWAL_PROG_PATH=\"${adcli}/bin/adcli\""
    "-I${libxml2.dev}/include/libxml2"
  ];

  preConfigure = ''
    export SGML_CATALOG_FILES="${docbookFiles}"
    export PATH=$PATH:${openldap}/libexec

    configureFlagsArray=(
      --prefix=$out
      --sysconfdir=/etc
      --localstatedir=/var
      --enable-pammoddir=$out/lib/security
      --with-os=fedora
      --with-pid-path=/run
      --with-python3-bindings
      --with-syslog=journald
      --with-initscript=systemd
      --without-selinux
      --without-semanage
      --with-xml-catalog-path=''${SGML_CATALOG_FILES%%:*}
      --with-ldb-lib-dir=$out/modules/ldb
      --with-nscd=${glibc.bin}/sbin/nscd
      --with-sssd-user=root
      --with-ldb-modules-path="${placeholder "out"}/modules/ldb:${ldb}/modules/ldb"
    )
  ''
  + lib.optionalString withSudo ''
    configureFlagsArray+=("--with-sudo")
  '';

  postInstall = ''
    rm -rf "$out"/run
    rm -rf "$out"/rc.d
    rm -f "$out"/modules/ldb/memberof.la
    find "$out" -depth -type d -exec rmdir --ignore-fail-on-non-empty {} \;
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = ''
    for f in $out/bin/sss{ctl,_cache,_debuglevel,_override,_seed}; do
      wrapProgram $f --prefix LDB_MODULES_PATH : $out/modules/ldb
    done
  '';

  enableParallelBuilding = true;
  # Disable parallel install due to missing depends:
  #   libtool:   error: error: relink '_py3sss.la' with the above command before installing i
  enableParallelInstalling = false;

  installFlags = [
    "sysconfdir=$(out)/etc"
    "localstatedir=$(out)/var"
    "pidpath=$(out)/run"
    "sss_statedir=$(out)/var/lib/sss"
    "logpath=$(out)/var/log/sssd"
    "pubconfpath=$(out)/var/lib/sss/pubconf"
    "dbpath=$(out)/var/lib/sss/db"
    "mcpath=$(out)/var/lib/sss/mc"
    "pipepath=$(out)/var/lib/sss/pipes"
    "gpocachepath=$(out)/var/lib/sss/gpo_cache"
    "secdbpath=$(out)/var/lib/sss/secrets"
    "initdir=$(out)/rc.d/init"
  ];

  separateDebugInfo = true;

  passthru = {
    tests = {
      inherit (nixosTests) sssd-ldap sssd-legacy-config;
      pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "System Security Services Daemon";
    homepage = "https://sssd.io/";
    changelog = "https://sssd.io/release-notes/sssd-${finalAttrs.version}.html";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      illustris
      liberodark
    ];

    platforms = lib.platforms.linux;

    pkgConfigModules = [
      "ipa_hbac"
      "sss_certmap"
      "sss_idmap"
      "sss_nss_idmap"
    ];
  };
})
