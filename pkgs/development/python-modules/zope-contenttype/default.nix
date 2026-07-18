{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zope-contenttype";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.contenttype";
    tag = version;
    hash = "sha256-fEbFFc6/R/fv9q9diKVcEPH12hVt/kbyGyNXqM8xzWM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zope.contenttype" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Utility module for content-type (MIME type) handling";
    homepage = "https://github.com/zopefoundation/zope.contenttype";
    changelog = "https://github.com/zopefoundation/zope.contenttype/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
