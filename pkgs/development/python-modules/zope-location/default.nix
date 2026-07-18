{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-component,
  zope-configuration,
  zope-copy,
  zope-interface,
  zope-proxy,
  zope-schema,
}:

buildPythonPackage rec {
  pname = "zope-location";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.location";
    tag = version;
    hash = "sha256-s7HZda+U87P62elX/KbDp2o9zAplgFVmnedDI/uq2sk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    zope-interface
    zope-proxy
    zope-schema
  ];

  optional-dependencies = {
    component = [ zope-component ];
    copy = [ zope-copy ];
    zcml = [ zope-configuration ];
  };

  pyproject = true;
  pythonImportsCheck = [ "zope.location" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/location/tests" ];

  meta = {
    description = "Zope Location";
    homepage = "https://github.com/zopefoundation/zope.location/";
    changelog = "https://github.com/zopefoundation/zope.location/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
