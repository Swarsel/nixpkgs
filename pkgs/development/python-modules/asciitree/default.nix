{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asciitree";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "mbr";
    repo = "asciitree";
    rev = version;
    hash = "sha256-AaLDO27W6fGHGU11rRpBf5gg1we+9SS1MEJdFP2lPBw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Draws ASCII trees";
    homepage = "https://github.com/mbr/asciitree";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
