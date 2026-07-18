{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "zope-i18nmessageid";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.i18nmessageid";
    tag = version;
    hash = "sha256-JDCbk7zh+9Ic5T3Pt1apQDN1Q59cLUdk5KCAIu5mlC4=";
  };

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.i18nmessageid" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/i18nmessageid" ];

  meta = {
    description = "Message Identifiers for internationalization";
    homepage = "https://github.com/zopefoundation/zope.i18nmessageid";
    changelog = "https://github.com/zopefoundation/zope.i18nmessageid/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
