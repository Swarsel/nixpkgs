{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gast,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "beniget";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "serge-sans-paille";
    repo = "beniget";
    tag = version;
    hash = "sha256-abxBLrz4JhZX084fd2wZEhP7w5bPBxvNXudYUaqS1Yo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ gast ];
  pyproject = true;
  pythonImportsCheck = [ "beniget" ];

  meta = {
    description = "Extract semantic information about static Python code";
    homepage = "https://github.com/serge-sans-paille/beniget";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
