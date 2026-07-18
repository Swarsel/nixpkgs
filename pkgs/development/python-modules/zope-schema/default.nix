{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-event,
  zope-i18nmessageid,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "zope-schema";
  version = "8.1";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.schema";
    tag = version;
    hash = "sha256-pO3yL0gej2PGD01ySiPJPU66P/9hW73T2n/ZnUPa3C0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [
    unittestCheckHook
    zope-i18nmessageid
  ];

  build-system = [ setuptools ];

  dependencies = [
    zope-event
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "zope.schema" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/schema/tests" ];

  meta = {
    description = "zope.interface extension for defining data schemas";
    homepage = "https://github.com/zopefoundation/zope.schema";
    changelog = "https://github.com/zopefoundation/zope.schema/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
