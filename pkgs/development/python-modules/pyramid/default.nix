{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hupper,
  pastedeploy,
  plaster,
  plaster-pastedeploy,
  pytestCheckHook,
  repoze-lru,
  setuptools_80,
  translationstring,
  venusian,
  webob,
  webtest,
  zope-component,
  zope-deprecation,
  zope-interface,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyramid";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "Pylons";
    repo = "pyramid";
    tag = finalAttrs.version;
    hash = "sha256-N0zH0BpS9ImSTWeADBOBSgLYI062sdLxTzwBENAawFc=";
  };

  nativeCheckInputs = [
    webtest
    zope-component
    pytestCheckHook
  ];

  build-system = [ setuptools_80 ];

  dependencies = [
    hupper
    pastedeploy
    plaster
    plaster-pastedeploy
    repoze-lru
    translationstring
    venusian
    webob
    zope-deprecation
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyramid" ];

  meta = {
    description = "Python web framework";
    homepage = "https://trypyramid.com/";
    changelog = "https://github.com/Pylons/pyramid/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
})
