{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  flit-scm,
  isPy3k,
  pytest-cov-stub,
  pytestCheckHook,
  sphinx,
  sympy,
}:

buildPythonPackage rec {
  pname = "measurement";
  version = "4.0a8";

  src = fetchFromGitHub {
    owner = "coddingtonbear";
    repo = "python-measurement";
    tag = version;
    hash = "sha256-QxXxx9Jbx7ykQFaw/3S6ANPUmw3mhvSa4np6crsfVtE=";
  };

  nativeBuildInputs = [
    flit-core
    flit-scm
    sphinx
  ];

  propagatedBuildInputs = [ sympy ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "Use and manipulate unit-aware measurement objects in Python";
    homepage = "https://github.com/coddingtonbear/python-measurement";
    changelog = "https://github.com/coddingtonbear/python-measurement/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
