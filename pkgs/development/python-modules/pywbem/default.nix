{
  lib,
  buildPythonPackage,
  decorator,
  fetchPypi,
  formencode,
  httpretty,
  libxml2,
  lxml,
  mock,
  nocasedict,
  nocaselist,
  pbr,
  ply,
  pytestCheckHook,
  pytz,
  pyyaml,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
  six,
  testfixtures,
  yamlloader,
}:

buildPythonPackage rec {
  pname = "pywbem";
  version = "1.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZcH/lyzqLwF7BnlfR8CtdEL4Q0/2Q6VEBQwQcmcE9qs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools-scm>=9.2.0" "setuptools-scm"
  '';

  propagatedBuildInputs = [
    mock
    nocasedict
    nocaselist
    pbr
    ply
    pyyaml
    requests
    six
    yamlloader
  ];

  nativeCheckInputs = [
    decorator
    formencode
    httpretty
    libxml2
    lxml
    pytestCheckHook
    pytz
    requests-mock
    testfixtures
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTestPaths = [
    "tests/leaktest" # requires 'yagot'
    "tests/end2endtest" # requires 'pytest_easy_server'
  ];

  pyproject = true;
  pythonImportsCheck = [ "pywbem" ];

  meta = {
    description = "Support for the WBEM standard for systems management";
    homepage = "https://pywbem.github.io";
    changelog = "https://github.com/pywbem/pywbem/blob/${version}/docs/changes.rst";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
