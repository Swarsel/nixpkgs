{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  bison,
  buildPackages,
  bzip2,
  composefs,
  curl,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  e2fsprogs,
  fuse3,
  gjs,
  glib,
  gobject-introspection,
  gpgme,
  gtk-doc,
  libarchive,
  libcap,
  libselinux,
  libsodium,
  libsoup_3,
  libtool,
  libxslt,
  makeWrapper,
  nixosTests,
  openssl,
  ostree-full,
  pkg-config,
  pkgsCross,
  python3,
  replaceVars,
  systemd,
  testers,
  util-linuxMinimal,
  which,
  xz,
  withComposefs ? false,
  withGjs ? lib.meta.availableOn stdenv.hostPlatform gjs,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

let
  testPython = python3.withPackages (
    p: with p; [
      pyyaml
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ostree";
  version = "2026.1";

  src = fetchurl {
    url = "https://github.com/ostreedev/ostree/releases/download/v${finalAttrs.version}/libostree-${finalAttrs.version}.tar.xz";
    hash = "sha256-jnfChd1vpexfsGMTA5CXe+cn/hEQczXth3ikA4UGnpU=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "installedTests"
  ];

  patches = [
    # Workarounds for installed tests failing in pseudoterminal
    # https://github.com/ostreedev/ostree/issues/1592
    ./fix-1592.patch

    # Hard-code paths in installed tests
    (replaceVars ./fix-test-paths.patch {
      openssl = "${openssl}/bin/openssl";
      python3 = testPython.interpreter;
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    glib
    gtk-doc
    which
    makeWrapper
    bison
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    curl
    glib
    e2fsprogs
    libsoup_3 # for trivial-httpd for tests
    gpgme
    fuse3
    libselinux
    libsodium
    libcap
    libarchive
    bzip2
    xz
    util-linuxMinimal # for libmount

    # for installed tests
    testPython
  ]
  ++ lib.optionals withComposefs [
    (lib.getDev composefs)
  ]
  ++ lib.optionals withGjs [
    gjs
  ]
  ++ lib.optionals withSystemd [
    systemd
  ];

  configureFlags = [
    "--with-curl"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-systemdsystemgeneratordir=${placeholder "out"}/lib/systemd/system-generators"
    "--enable-installed-tests"
    "--with-ed25519-libsodium"
  ]
  ++ lib.optionals withComposefs [
    "--with-composefs"
  ];

  makeFlags = [
    "installed_testdir=${placeholder "installedTests"}/libexec/installed-tests/libostree"
    "installed_test_metadir=${placeholder "installedTests"}/share/installed-tests/libostree"
    # Setting this flag was required as workaround for a clang bug, but seems not relevant anymore.
    # https://github.com/ostreedev/ostree/commit/fd8795f3874d623db7a82bec56904648fe2c1eb7
    # See also Makefile-libostree.am
    "INTROSPECTION_SCANNER_ENV="
  ];

  preConfigure = ''
    env NOCONFIGURE=1 ./autogen.sh
  '';

  postFixup =
    let
      typelibPath = lib.makeSearchPath "/lib/girepository-1.0" [
        (placeholder "out")
        glib.out
      ];
    in
    lib.optionalString withIntrospection ''
      for test in $installedTests/libexec/installed-tests/libostree/*.js; do
        wrapProgram "$test" --prefix GI_TYPELIB_PATH : "${typelibPath}"
      done
    '';

  enableParallelBuilding = true;

  passthru = {
    tests = {
      inherit ostree-full;
      installedTests = nixosTests.installed-tests.ostree;
      musl = pkgsCross.musl64.ostree;

      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    description = "Git for operating system binaries";
    homepage = "https://ostreedev.github.io/ostree/";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    pkgConfigModules = [ "ostree-1" ];
  };
})
