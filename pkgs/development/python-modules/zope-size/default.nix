{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-component,
  zope-configuration,
  zope-i18nmessageid,
  zope-interface,
  zope-security,
}:

buildPythonPackage rec {
  pname = "zope-size";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.size";
    tag = version;
    hash = "sha256-jjI9NvfxnIWZrqDEpZ6FDlhDWZoqEUBliiyh+5PxOAg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [
    unittestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    zope-i18nmessageid
    zope-interface
  ];

  optional-dependencies = {
    zcml = [
      zope-component
      zope-configuration
      zope-security
    ]
    ++ zope-component.optional-dependencies.zcml
    ++ zope-security.optional-dependencies.zcml;
  };

  pyproject = true;
  pythonImportsCheck = [ "zope.size" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/size" ];

  meta = {
    description = "Interfaces and simple adapter that give the size of an object";
    homepage = "https://github.com/zopefoundation/zope.size";
    changelog = "https://github.com/zopefoundation/zope.size/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
