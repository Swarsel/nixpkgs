{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  c-ares,
  cmake,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchpatch,
  libev,
  libsodium,
  libxslt,
  mbedtls,
  nix-update-script,
  nixosTests,
  pcre2,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shadowsocks-libev";
  version = "3.3.6";

  # Git tag includes CMake build files which are much more convenient.
  src = fetchFromGitHub {
    owner = "shadowsocks";
    repo = "shadowsocks-libev";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XrS/qi4oAchdisvicrGmpe3jeDgYDACsvVU6iXQyQCM=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace cmake/shadowsocks-libev.pc.cmake \
      --replace-fail '$'{prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
      --replace-fail '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@ \

    # https://github.com/dcreager/libcork/issues/173 but needs a different patch (yay vendoring)
    substituteInPlace libcork/src/libcork.pc.in \
      --replace-fail '$'{exec_prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
      --replace-fail '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    asciidoc
    xmlto
    docbook_xml_dtd_45
    docbook_xsl
    libxslt
  ];

  buildInputs = [
    libsodium
    mbedtls
    libev
    c-ares
    pcre2
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_STATIC" false)
    (lib.cmakeBool "-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR" true)
    # RPATH of binary /nix/store/.../bin/... contains a forbidden reference to /build/
    (lib.cmakeBool "-DCMAKE_SKIP_BUILD_RPATH" true)
  ];

  postInstall = ''
    cp lib/* $out/lib
  '';

  __structuredAttrs = true;

  passthru = {
    tests = lib.recurseIntoAttrs {
      inherit (nixosTests.shadowsocks) basic-libev v2ray-plugin-libev;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight secured SOCKS5 proxy";

    longDescription = ''
      Shadowsocks-libev is a lightweight secured SOCKS5 proxy for embedded devices and low-end boxes.
      It is a port of Shadowsocks created by @clowwindy, which is maintained by @madeye and @linusyang.
    '';

    homepage = "https://github.com/shadowsocks/shadowsocks-libev";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hmenke ];
    platforms = lib.platforms.all;
  };
})
