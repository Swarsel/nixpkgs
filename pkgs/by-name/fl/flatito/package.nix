{
  lib,
  buildRubyGem,
  bundlerEnv,
  bundlerUpdateScript,
  ruby,
}:
let
  deps = bundlerEnv rec {
    inherit ruby;
    version = "0.1.1";
    gemdir = ./.;

    gemset = lib.recursiveUpdate (import ./gemset.nix) {
      flatito.source = {
        remotes = [ "https://rubygems.org" ];
        sha256 = "9f5a8f899a14c1a0fe74cb89288f24ddc47bd5d83ac88ac8023d19b056ecb50f";
        type = "gem";
      };
    };

    name = "flatito-${version}";
  };
in

buildRubyGem rec {
  inherit ruby;
  pname = gemName;
  version = "0.1.1";
  propagatedBuildInputs = [ deps ];
  gemName = "flatito";
  source.sha256 = "sha256-n1qPiZoUwaD+dMuJKI8k3cR71dg6yIrIAj0ZsFbstQ8=";
  passthru.updateScript = bundlerUpdateScript "${pname}";

  meta = {
    description = "Grep for keys in YAML and JSON files";
    homepage = "https://github.com/ceritium/flatito";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rucadi ];
    platforms = lib.platforms.unix;
    mainProgram = "flatito";
  };
}
