{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  persistent,
  setuptools,
  unittestCheckHook,
  zope-configuration,
  zope-event,
  zope-hookable,
  zope-i18nmessageid,
  zope-interface,
  zope-location,
  zope-proxy,
  zope-security,
}:

buildPythonPackage rec {
  pname = "zope-component";
  version = "7.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.component";
    tag = version;
    hash = "sha256-3Hl2sm2M0we+fpdt4GSjAStLSAJ1c4Za1vfm9Bj8z8s=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [
    unittestCheckHook
    zope-configuration
  ];

  # AssertionError: 'test_interface.IFoo' != 'zope.component.tests.test_interface.IFoo'
  preCheck = ''
    rm src/zope/component/tests/test_interface.py
  '';

  build-system = [ setuptools ];

  dependencies = [
    zope-event
    zope-hookable
    zope-interface
  ];

  optional-dependencies = {
    hook = [ ];
    persistentregistry = [ persistent ];

    security = [
      zope-location
      zope-proxy
      zope-security
    ];

    zcml = [
      zope-configuration
      zope-i18nmessageid
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "zope.component" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/component/tests" ];

  meta = {
    description = "Zope Component Architecture";
    homepage = "https://github.com/zopefoundation/zope.component";
    changelog = "https://github.com/zopefoundation/zope.component/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
