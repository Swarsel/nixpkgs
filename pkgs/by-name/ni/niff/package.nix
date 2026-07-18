{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

let
  version = "0.1";
in
stdenv.mkDerivation {
  inherit version;
  pname = "niff";

  src = fetchFromGitHub {
    owner = "FRidh";
    repo = "niff";
    rev = "v${version}";
    sha256 = "1ziv5r57jzg2qg61izvkkyq1bz4p5nb6652dzwykfj3l2r3db4bi";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/bin
    cp niff $out/bin/niff
  '';

  dontBuild = true;

  meta = {
    description = "Program that compares two Nix expressions and determines which attributes changed";
    homepage = "https://github.com/FRidh/niff";
    license = lib.licenses.mit;
    mainProgram = "niff";
  };
}
