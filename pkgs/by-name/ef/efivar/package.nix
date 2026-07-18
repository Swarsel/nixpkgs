{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  mandoc,
  pkg-config,
  popt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "efivar";
  version = "39";

  src = fetchFromGitHub {
    owner = "rhboot";
    repo = "efivar";
    rev = finalAttrs.version;
    hash = "sha256-s/1k5a3n33iLmSpKQT5u08xoj8ypjf2Vzln88OBrqf0=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    mandoc
  ];

  buildInputs = [ popt ];

  makeFlags = [
    "prefix=$(out)"
    "libdir=$(out)/lib"
    "bindir=$(bin)/bin"
    "mandir=$(man)/share/man"
    "includedir=$(dev)/include"
    "PCDIR=$(dev)/lib/pkgconfig"
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    description = "Tools and library to manipulate EFI variables";
    homepage = "https://github.com/rhboot/efivar";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    # See https://github.com/NixOS/nixpkgs/issues/388309
    broken = stdenv.hostPlatform.is32bit;
  };
})
