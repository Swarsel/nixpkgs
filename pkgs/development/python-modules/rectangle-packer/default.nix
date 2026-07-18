{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rectangle-packer";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "Penlect";
    repo = "rectangle-packer";
    rev = version;
    hash = "sha256-BHFy88yrcfDRalvrzwUHseSKmQXIM70ginnd+W6LVLY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -r rpack
  '';

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "rpack" ];

  meta = {
    description = "Pack a set of rectangles into a bounding box with minimum area";
    homepage = "https://github.com/Penlect/rectangle-packer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fbeffa ];
  };
}
