{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "zope-event";
  version = "6.2";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.event";
    tag = finalAttrs.version;
    hash = "sha256-FoE9bdr/JcOaB8/OQTUmxGrNgIDc1vPDlmZq0v+bjmQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];
  enabledTestPaths = [ "src/zope/event/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "zope.event" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Event publishing system";
    homepage = "https://github.com/zopefoundation/zope.event";
    changelog = "https://github.com/zopefoundation/zope.event/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
})
