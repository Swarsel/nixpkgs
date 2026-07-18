{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "simplefix";
  version = "1.0.17";

  src = fetchFromGitHub {
    owner = "da4089";
    repo = "simplefix";
    tag = "v${version}";
    hash = "sha256-D85JW3JRQ1xErw6krMbAg94WYjPi76Xqjv/MGNMY5ZU=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "simplefix" ];

  unittestFlagsArray = [
    "-s"
    "test"
  ];

  meta = {
    description = "Simple FIX Protocol implementation for Python";
    homepage = "https://github.com/da4089/simplefix";
    changelog = "https://github.com/da4089/simplefix/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
