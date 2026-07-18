# Heavily based on
# https://github.com/risicle/nix-heuristic-gc/blob/0.6.0/default.nix
{
  lib,
  fetchFromGitHub,
  boost,
  nixVersions,
  pkg-config,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "nix-heuristic-gc";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "risicle";
    repo = "nix-heuristic-gc";
    tag = "v${version}";
    hash = "sha256-T/PKn005gkALJP2FfHfWJj5UIRP9IYkvMOT3+kMY3Wo=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    boost
    nixVersions.nixComponents_2_31.nix-store
    nixVersions.nixComponents_2_31.nix-main
    python3Packages.pybind11
    python3Packages.setuptools
  ];

  propagatedBuildInputs = [
    python3Packages.humanfriendly
    python3Packages.rustworkx
  ];

  # NIX_SYSTEM suggested at
  # https://github.com/NixOS/nixpkgs/issues/386184#issuecomment-2692433531
  env.NIX_SYSTEM = nixVersions.nixComponents_2_31.nix-store.stdenv.hostPlatform.system;
  checkInputs = [ python3Packages.pytestCheckHook ];
  preCheck = "mv nix_heuristic_gc .nix_heuristic_gc";
  format = "setuptools";

  meta = {
    description = "Discerning garbage collection for Nix";

    longDescription = ''
      A more discerning cousin of `nix-collect-garbage`, mostly intended as a
      testbed to allow experimentation with more advanced selection processes.
    '';

    homepage = "https://github.com/risicle/nix-heuristic-gc";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      ris
      me-and
    ];

    mainProgram = "nix-heuristic-gc";
  };
}
