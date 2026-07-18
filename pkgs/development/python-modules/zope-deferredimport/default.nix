{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
  zope-proxy,
}:

buildPythonPackage rec {
  pname = "zope-deferredimport";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.deferredimport";
    tag = version;
    hash = "sha256-7Q8+Cew5987+CjUOxqpwMFXWdw+/B28tOEXRYC0SRyI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ zope-proxy ];
  pyproject = true;
  pythonImportsCheck = [ "zope.deferredimport" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/deferredimport" ];

  meta = {
    description = "Allows you to perform imports names that will only be resolved when used in the code";
    homepage = "https://github.com/zopefoundation/zope.deferredimport";
    changelog = "https://github.com/zopefoundation/zope.deferredimport/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
  };
}
