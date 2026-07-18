{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pillow,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "minexr";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "cheind";
    repo = "py-minexr";
    tag = version;
    hash = "sha256-p42rlhaHq0A9+zk6c0evRDjNR1H/ruWJqPF5+nCTR8o=";
  };

  propagatedBuildInputs = [ numpy ];

  nativeCheckInputs = [
    pytestCheckHook
    pillow
  ];

  format = "setuptools";
  pythonImportsCheck = [ "minexr" ];

  meta = {
    description = "Minimal, standalone OpenEXR reader for single-part, uncompressed scan line files";
    homepage = "https://github.com/cheind/py-minexr";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
