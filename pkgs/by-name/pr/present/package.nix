{
  lib,
  fetchPypi,
  python3Packages,
}:

let
  # https://github.com/NixOS/nixpkgs/issues/348788
  pythonPackages = python3Packages.overrideScope (
    self: super: {
      mistune = self.mistune_2;
    }
  );
in
pythonPackages.buildPythonPackage rec {
  pname = "present";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-l9W5L4LD9qRo3rLBkgd2I/aDaj+ucib5UYg+X4RYg6c=";
  };

  # TypeError: don't know how to make test from: 0.6.0
  doCheck = false;
  build-system = with pythonPackages; [ setuptools ];

  dependencies = with pythonPackages; [
    click
    pyyaml
    pyfiglet
    asciimatics
    mistune
  ];

  pyproject = true;
  pythonImportsCheck = [ "present" ];

  meta = {
    description = "Terminal-based presentation tool with colors and effects";
    homepage = "https://github.com/vinayak-mehta/present";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "present";
  };
}
