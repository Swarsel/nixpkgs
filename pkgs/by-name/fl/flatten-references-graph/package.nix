{
  callPackage,
  nix-gitignore,
  python3Packages,
}:
let
  helpers = callPackage ./helpers.nix { };
  pythonPackages = python3Packages;

in
pythonPackages.buildPythonApplication {
  pname = "flatten-references-graph";
  version = "0.1.0";
  # Note: this uses only ./src/.gitignore
  src = nix-gitignore.gitignoreSource [ ] ./src;
  doCheck = true;

  checkPhase = ''
    ${helpers.unittest}/bin/unittest
  '';

  build-system = with pythonPackages; [
    setuptools
  ];

  dependencies = with pythonPackages; [
    igraph
    toolz
  ];

  pyproject = true;

  passthru = {
    dev-shell = callPackage ./dev-shell.nix { };
  };
}
