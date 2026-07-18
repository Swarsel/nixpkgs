{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rfc8785";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "rfc8785.py";
    tag = "v${version}";
    hash = "sha256-0Gze3voFXEhf13DuTuBWDbYPmqHXs0FSRn2NprFWoB8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    flit-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "rfc8785" ];

  meta = {
    description = "Module for RFC8785 (JSON Canonicalization Scheme)";
    homepage = "https://github.com/trailofbits/rfc8785.py";
    changelog = "https://github.com/trailofbits/rfc8785.py/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
