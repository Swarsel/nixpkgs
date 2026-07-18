{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  maya,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "secure";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "typeerror";
    repo = "secure.py";
    tag = "v${version}";
    hash = "sha256-lyosOejztFEINGKO0wAYv3PWBL7vpmAq+eQunwP9h5I=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    maya
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "secure" ];

  meta = {
    description = "Adds optional security headers and cookie attributes for Python web frameworks";
    homepage = "https://github.com/TypeError/secure.py";
    changelog = "https://github.com/TypeError/secure/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
