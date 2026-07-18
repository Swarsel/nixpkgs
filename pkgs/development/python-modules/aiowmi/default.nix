{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycryptodome,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiowmi";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "cesbit";
    repo = "aiowmi";
    tag = "v${version}";
    hash = "sha256-bKxGIUxGAW1GDa5xlv9NNWr5xLTdpK5dSsym/5y9nGQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pycryptodome ];
  pyproject = true;
  pythonImportsCheck = [ "aiowmi" ];

  meta = {
    description = "Python WMI Queries";
    homepage = "https://github.com/cesbit/aiowmi";
    changelog = "https://github.com/cesbit/aiowmi/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
