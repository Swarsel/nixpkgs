{
  lib,
  fetchFromGitHub,
  btrees,
  buildPythonPackage,
  pytz,
  setuptools,
  unittestCheckHook,
  zope-component,
  zope-configuration,
  zope-exceptions,
  zope-i18nmessageid,
  zope-interface,
  zope-location,
  zope-proxy,
  zope-schema,
  zope-testing,
}:

buildPythonPackage rec {
  pname = "zope-security";
  version = "8.3";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.security";
    tag = version;
    hash = "sha256-iSWSBjtJe4iEvm+VUEWDvRCBdRz1R6m9mlfPLwh01Sk=";
  };

  nativeCheckInputs = [
    btrees
    unittestCheckHook
    zope-exceptions
    zope-testing
  ]
  ++ lib.concatAttrValues optional-dependencies;

  # Import process is too complex and some tests fail
  preCheck = ''
    rm -r src/zope/security/tests/test_metaconfigure.py
    rm -r src/zope/security/tests/test_proxy.py
    rm -r src/zope/security/tests/test_zcml_functest.py
  '';

  build-system = [
    setuptools
    zope-proxy
  ];

  dependencies = [
    zope-component
    zope-i18nmessageid
    zope-interface
    zope-location
    zope-proxy
    zope-schema
  ];

  optional-dependencies = {
    pytz = [ pytz ];
    # untrustedpython = [ zope-untrustedpython ];
    zcml = [ zope-configuration ];
  };

  pyproject = true;
  pythonImportsCheck = [ "zope.security" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/security/tests" ];

  meta = {
    description = "Zope Security Framework";
    homepage = "https://github.com/zopefoundation/zope.security";
    changelog = "https://github.com/zopefoundation/zope.security/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
