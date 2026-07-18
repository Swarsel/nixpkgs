{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  iptables,
  libnl,
  nixosTests,
  pkg-config,
}:

let
  sourceAttrs = (import ./source.nix) { inherit fetchFromGitHub; };
in

stdenv.mkDerivation {
  pname = "jool-cli";
  version = sourceAttrs.version;
  src = sourceAttrs.src;

  outputs = [
    "out"
    "man"
  ];

  patches = [ ./validate-config.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libnl
    iptables
  ];

  makeFlags = [
    "-C"
    "src/usr"
  ];

  prePatch = ''
    sed -e 's%^XTABLES_SO_DIR = .*%XTABLES_SO_DIR = '"$out"'/lib/xtables%g' -i src/usr/iptables/Makefile
  '';

  passthru.tests = {
    inherit (nixosTests) jool;
  };

  meta = {
    description = "Fairly compliant SIIT and Stateful NAT64 for Linux - CLI tools";
    homepage = "https://www.jool.mx/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
  };
}
