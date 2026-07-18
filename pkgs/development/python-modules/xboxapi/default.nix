{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "xboxapi";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "mKeRix";
    repo = "xboxapi-python";
    tag = version;
    hash = "sha256-rX3lrXzUYqyRyI89fbCEEMevTdi5SBgSp8XxSanasII=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "xboxapi" ];

  meta = {
    description = "Python XBOX One API wrapper";
    homepage = "https://github.com/mKeRix/xboxapi-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
