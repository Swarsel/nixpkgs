{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cpe";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "nilp0inter";
    repo = "cpe";
    tag = "v${version}";
    hash = "sha256-QI5XHy2TDSUqK6BZBoFWViBcOKfo+zg0ulzEzF4eg4w=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cpe" ];

  meta = {
    description = "Common platform enumeration for python";
    homepage = "https://github.com/nilp0inter/cpe";
    changelog = "https://github.com/nilp0inter/cpe/releases/tag/v${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ tochiaha ];
  };
}
