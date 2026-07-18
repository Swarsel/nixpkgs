{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyjvcprojector";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "SteveEasley";
    repo = "pyjvcprojector";
    tag = "v${version}";
    hash = "sha256-HFnaMIlF+C2fi8NlMtQKEMY35lAS15ij4QyFMFYhiU8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "jvcprojector" ];

  meta = {
    description = "Python library for controlling a JVC Projector over a network connection";
    homepage = "https://github.com/SteveEasley/pyjvcprojector";
    changelog = "https://github.com/SteveEasley/pyjvcprojector/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
