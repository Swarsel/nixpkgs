{
  lib,
  stdenv,
  fetchFromGitHub,
  argparse,
  autoconf,
  automake,
  cmake,
  fetchpatch,
  libtool,
  mosquitto,
  openssl,
  pkg-config,
  pkgs,
}:

stdenv.mkDerivation rec {
  pname = "ebusd";
  version = "26.1";

  src = fetchFromGitHub {
    owner = "john30";
    repo = "ebusd";
    rev = version;
    sha256 = "sha256-CmArhkJfxf8lL6FoHRQKjk/8ObfEy3Xef9DUtOVKRas=";
  };

  patches = [
    ./patches/ebusd-cmake.patch
  ];

  nativeBuildInputs = [
    cmake
    autoconf
    automake
    libtool
    pkg-config
  ];

  buildInputs = [
    argparse
    mosquitto
    openssl
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
    "-DCMAKE_INSTALL_BINDIR=${placeholder "out"}/bin"
    "-DCMAKE_INSTALL_LOCALSTATEDIR=${placeholder "TMPDIR"}"
  ];

  preInstall = ''
    mkdir -p $out/usr/bin
  '';

  postInstall = ''
    rmdir $out/usr/bin
    rmdir $out/usr
  '';

  meta = {
    description = "ebusd";
    homepage = "https://github.com/john30/ebusd";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nathan-gs ];
    platforms = lib.platforms.linux;
  };
}
