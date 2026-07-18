{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "noiseprotocol";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "plizonczyk";
    repo = "noiseprotocol";
    tag = "v${version}";
    hash = "sha256-VZkKNxeSxLhRDhrj4VKV/1eXl7RtcsnCHru5KC/OYNY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "noise" ];

  meta = {
    description = "Noise Protocol Framework";
    homepage = "https://github.com/plizonczyk/noiseprotocol/";
    changelog = "https://github.com/plizonczyk/noiseprotocol/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
