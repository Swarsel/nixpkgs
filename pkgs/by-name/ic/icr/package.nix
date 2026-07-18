{
  lib,
  fetchFromGitHub,
  crystal,
  libyaml,
  makeWrapper,
  openssl,
  pkg-config,
  readline,
  shards,
  which,
  zlib,
}:

crystal.buildCrystalPackage rec {
  pname = "icr";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "crystal-community";
    repo = "icr";
    rev = "v${version}";
    hash = "sha256-29B/i8oEjwNOYjnc78QcYTl6fC/M9VfAVCCBjLBKp0Q=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    which
  ];

  buildInputs = [
    libyaml
    openssl
    readline
    zlib
  ];

  # tests are failing due to our sandbox
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/icr \
      --prefix PATH : ${
        lib.makeBinPath [
          crystal
          shards
          which
        ]
      }
  '';

  shardsFile = ./shards.nix;

  meta = {
    description = "Interactive console for the Crystal programming language";
    homepage = "https://github.com/crystal-community/icr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "icr";
  };
}
