{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  version = "0.3.2";
in
python3Packages.buildPythonPackage rec {
  inherit version;
  pname = "tesh";

  src = fetchFromGitHub {
    owner = "OceanSprint";
    repo = "tesh";
    rev = version;
    hash = "sha256-GIwg7Cv7tkLu81dmKT65c34eeVnRR5MIYfNwTE7j2Vs=";
  };

  nativeBuildInputs = [ python3Packages.poetry-core ];

  propagatedBuildInputs = with python3Packages; [
    click
    pexpect
    distutils
  ];

  checkInputs = [ python3Packages.pytest ];
  pyproject = true;

  meta = {
    homepage = "https://github.com/OceanSprint/tesh";
    license = lib.licenses.mit;
  };
}
