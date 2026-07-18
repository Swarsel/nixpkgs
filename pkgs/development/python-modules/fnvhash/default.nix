{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "fnvhash";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "znerol";
    repo = "py-fnvhash";
    tag = "v${version}";
    hash = "sha256-vAflKSvi0PD5r1q6GCTt6a4vTCsdBIebecRCKbbBphE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "fnvhash" ];

  meta = {
    description = "Python FNV hash implementation";
    homepage = "https://github.com/znerol/py-fnvhash";
    changelog = "https://github.com/znerol/py-fnvhash/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
