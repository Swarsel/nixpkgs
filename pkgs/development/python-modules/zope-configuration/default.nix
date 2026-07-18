{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  setuptools,
  unittestCheckHook,
  zope-i18nmessageid,
  zope-interface,
  zope-schema,
}:

buildPythonPackage rec {
  pname = "zope-configuration";
  version = "7.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.configuration";
    tag = version;
    hash = "sha256-G87VAEqMxF5Y3LuDJnDcOox5+ngJuRhUGSj9K8c3mYY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ unittestCheckHook ];

  preCheck = ''
    cd $out/${python.sitePackages}/zope/
  '';

  build-system = [ setuptools ];

  dependencies = [
    zope-i18nmessageid
    zope-interface
    zope-schema
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.configuration" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "configuration/tests" ];

  meta = {
    description = "Zope Configuration Markup Language (ZCML)";
    homepage = "https://github.com/zopefoundation/zope.configuration";
    changelog = "https://github.com/zopefoundation/zope.configuration/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
