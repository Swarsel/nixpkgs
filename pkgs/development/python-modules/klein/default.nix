{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  hyperlink,
  # tests
  idna,
  incremental,
  python,
  # build-system
  setuptools,
  treq,
  tubes,
  twisted,
  werkzeug,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "klein";
  version = "24.8.0";

  src = fetchFromGitHub {
    owner = "twisted";
    repo = "klein";
    tag = version;
    hash = "sha256-2/zl4fS9ZP73quPmGnz2+brEt84ODgVS89Om/cUsj0M=";
  };

  nativeCheckInputs = [
    idna
    treq
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m twisted.trial klein
    runHook postCheck
  '';

  build-system = [
    incremental
    setuptools
  ];

  dependencies = [
    attrs
    hyperlink
    incremental
    twisted
    tubes
    werkzeug
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "klein" ];

  meta = {
    description = "Klein Web Micro-Framework";
    homepage = "https://github.com/twisted/klein";
    changelog = "https://github.com/twisted/klein/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ exarkun ];
  };
}
