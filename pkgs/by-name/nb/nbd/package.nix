{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bison,
  docbook2x,
  docbook_sgml_dtd_41,
  docbook_sgml_dtd_45,
  fetchpatch,
  flex,
  glib,
  gnutls,
  libnl,
  linuxHeaders,
  nixosTests,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nbd";
  version = "3.27.1";

  src = fetchFromGitHub {
    owner = "NetworkBlockDevice";
    repo = "nbd";
    tag = "nbd-${finalAttrs.version}";
    hash = "sha256-0ahoLnwLdQdpr0AuRpNoid17hXo9BWlIOWRjRwhJ/LM=";
  };

  patches = [
    # Fix nbd device parsing
    (fetchpatch {
      hash = "sha256-PMgVz2a8cwv1tO8ac5Wrf8ZFvOmCq+mC5bysJJGhpGc=";
      url = "https://github.com/NetworkBlockDevice/nbd/commit/a80304e10e9709d4100c935bc4cdc9086e86d5ff.patch";
    })
  ];

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail "support/genver.sh" "echo ${finalAttrs.version}"
    substituteInPlace man/Makefile.am \
      --replace-fail "docbook2man" "docbook2man --sgml"
  '';

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
    bison
    flex
    docbook2x # docbook2man
  ];

  buildInputs = [
    glib
    gnutls
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libnl
    linuxHeaders
  ];

  configureFlags = [
    "--sysconfdir=/etc"
  ];

  env.SGML_CATALOG_FILES = lib.concatStringsSep ":" [
    "${docbook_sgml_dtd_41}/sgml/dtd/docbook-4.1/docbook.cat"
    "${docbook_sgml_dtd_45}/sgml/dtd/docbook-4.5/docbook.cat"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    which
  ];

  passthru.tests = {
    test = nixosTests.nbd;
  };

  meta = {
    description = "Map arbitrary files as block devices over the network";
    homepage = "https://nbd.sourceforge.io/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.unix;
  };
})
