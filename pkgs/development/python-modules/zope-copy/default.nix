{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zodbpickle,
  zope-interface,
  zope-location,
  zope-schema,
}:

buildPythonPackage rec {
  pname = "zope-copy";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.copy";
    tag = version;
    hash = "sha256-hYeLUSwAq5rK4TRngvNQGR4Fdimb2k5dHtFdptMVqPo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [
    unittestCheckHook
    zope-location
    zope-schema
  ];

  build-system = [ setuptools ];

  dependencies = [
    zodbpickle
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.copy" ];
  pythonNamespaces = [ "zope" ];

  unittestFlagsArray = [
    "-s"
    "src/zope/copy"
  ];

  meta = {
    description = "Pluggable object copying mechanism";
    homepage = "https://github.com/zopefoundation/zope.copy";
    changelog = "https://github.com/zopefoundation/zope.copy/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
