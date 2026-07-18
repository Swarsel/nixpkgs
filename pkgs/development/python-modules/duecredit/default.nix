{
  lib,
  buildPythonPackage,
  citeproc-py,
  fetchPypi,
  looseversion,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "duecredit";
  version = "0.11.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-e1wa4Qkn+eAs9NVOLHSoqgDNKcONY33v48lI09jp8zo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    vcrpy
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    citeproc-py
    looseversion
    requests
  ];

  disabledTests = [ "test_import_doi" ]; # tries to access network
  pyproject = true;
  pythonImportsCheck = [ "duecredit" ];

  meta = {
    description = "Simple framework to embed references in code";
    homepage = "https://github.com/duecredit/duecredit";
    changelog = "https://github.com/duecredit/duecredit/releases/tag/${version}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.bcdarwin ];
    mainProgram = "duecredit";
  };
}
