{
  lib,
  stdenv,
  bashInteractive,
  bison,
  buildPackages,
  fetchpatch,
  flex,
  # apparmor deps
  libapparmor,
  # testing
  perl,
  python3,
  runtimeShellPackage,
  which,
  zstd,
  linuxHeaders ? stdenv.cc.libc.linuxHeaders,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (libapparmor) version src;
  pname = "apparmor-parser";

  patches = [
    (fetchpatch {
      hash = "sha256-7c5EFByrGIDj2lc31bRttyeybwndDm4iS4qdPMVaG/I=";
      # https://gitlab.com/apparmor/apparmor/-/merge_requests/2133
      # Patches generated yacc parser code to compile with format-security
      url = "https://gitlab.com/apparmor/apparmor/-/commit/6bdec74d5e74660b97e00b4b8fafc014b05907b7.diff";
    })
  ];

  postPatch = ''
    patchShebangs .
    cd parser

    substituteInPlace Makefile \
      --replace-fail "/usr/include/linux/capability.h" "${linuxHeaders}/include/linux/capability.h"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bison
    flex
    which
  ];

  buildInputs = [
    libapparmor
    zstd
    runtimeShellPackage
  ];

  makeFlags = [
    "LANGS="
    "USE_SYSTEM=1"
    "INCLUDEDIR=${libapparmor}/include"
    "AR=${stdenv.cc.bintools.targetPrefix}ar"
    "POD2MAN=${lib.getExe' buildPackages.perl "pod2man"}"
    "POD2HTML=${lib.getExe' buildPackages.perl "pod2html"}"
    "MANDIR=share/man"
  ]
  ++ lib.optional finalAttrs.doCheck "PROVE=${lib.getExe' perl "prove"}";

  doCheck = stdenv.hostPlatform == stdenv.buildPlatform;

  nativeCheckInputs = [
    bashInteractive
    perl
    python3
  ];

  preCheck = "pushd ./tst";
  postCheck = "popd";
  checkTarget = "tests";

  installFlags = [
    "DESTDIR=$(out)"
    "DISTRO=unknown"
  ];

  meta = libapparmor.meta // {
    description = "Mandatory access control system - core library";
    mainProgram = "apparmor_parser";
  };
})
