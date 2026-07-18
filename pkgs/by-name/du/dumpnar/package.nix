{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "dumpnar";
  version = "0-unstable-2023-01-01";

  src = fetchFromGitHub {
    owner = "stephank";
    repo = "dumpnar";
    rev = "7b05e204264183532e8592ad132f74ddf05bc428";
    hash = "sha256-762vgCn2d6QoXRBjpe/SyHKgyQJAV0sEl1prcyf/ClE=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dumpnar $out/bin/
  '';

  meta = {
    description = "Minimal tool to produce a Nix NAR archive";
    homepage = "https://github.com/stephank/dumpnar";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.stephank ];
    platforms = lib.platforms.all;
    mainProgram = "dumpnar";
  };
}
