{
  lib,
  stdenv,
  fetchFromGitHub,
  cmocka,
  json_c,
  libaio,
  liburcu,
  linuxHeaders,
  lvm2,
  nixosTests,
  perl,
  pkg-config,
  readline,
  systemd,
  udevCheckHook,
  util-linuxMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "multipath-tools";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "opensvc";
    repo = "multipath-tools";
    tag = finalAttrs.version;
    hash = "sha256-uppx79+ZWazGM/QQ+8jeTogqXyHosiFfcnH2npiz7W0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    perl
    pkg-config
    udevCheckHook
  ];

  buildInputs = [
    json_c
    libaio
    liburcu
    linuxHeaders
    lvm2
    readline
    systemd
    util-linuxMinimal # for libmount
  ];

  makeFlags = [
    "WARN_ONLY=1"
    "LIB=lib"
    "prefix=$(out)"
    "systemd_prefix=$(out)"
    "etc_prefix=/"
    "kernel_incdir=${linuxHeaders}/include/"
    "man8dir=$(out)/share/man/man8"
    "man5dir=$(out)/share/man/man5"
    "man3dir=$(out)/share/man/man3"
  ];

  doCheck = true;
  checkInputs = [ cmocka ];

  preCheck = ''
    # skip test attempting to access /sys/dev/block
    substituteInPlace tests/Makefile --replace-fail ' devt ' ' '
  '';

  doInstallCheck = true;
  passthru.tests = { inherit (nixosTests) iscsi-multipath-root; };

  meta = {
    description = "Tools for the Linux multipathing storage driver";
    homepage = "http://christophe.varoqui.free.fr/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
