{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "zope-hookable";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.hookable";
    tag = version;
    hash = "sha256-pryx55dzvg+6jSUj4avskTnGKe6w1HkEh6v6OOlHIXY=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zope.hookable" ];
  pythonNamespaces = [ "zope" ];
  unittestFlagsArray = [ "src/zope/hookable/tests" ];

  meta = {
    description = "Supports the efficient creation of “hookable” objects";
    homepage = "https://github.com/zopefoundation/zope.hookable";
    changelog = "https://github.com/zopefoundation/zope.hookable/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
  };
}
