{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

let
  version = "0.5.1";
in
stdenv.mkDerivation {
  inherit version;
  pname = "nix-lib-nmt";

  src = fetchFromSourcehut {
    owner = "~rycee";
    repo = "nmt";
    rev = "v${version}";
    hash = "sha256-krVKx3/u1mDo8qe5qylYgmwAmlAPHa1BSPDzxq09FmI=";
  };

  installPhase = ''
    mkdir -pv "$out"
    cp -rv * "$out"
  '';

  outputHash = "sha256-N7kGGDDXsXtc1S3Nqw7lCIbnVHtGNNLM1oO+Xe64hSE=";
  outputHashMode = "recursive";

  meta = {
    description = "Basic test framework for projects using the Nixpkgs module system";
    homepage = "https://git.sr.ht/~rycee/nmt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rycee ];
  };
}
