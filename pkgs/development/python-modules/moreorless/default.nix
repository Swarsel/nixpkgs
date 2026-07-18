{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  parameterized,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "moreorless";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "thatch";
    repo = "moreorless";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uFcNjQLr/rO2hf2ujWWSsOVxfwgAeIxDZ0yskOfBSe4=";
  };

  nativeCheckInputs = [
    parameterized
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ click ];
  pyproject = true;
  pythonImportsCheck = [ "moreorless" ];

  meta = {
    description = "Wrapper to make difflib.unified_diff more fun to use";
    homepage = "https://github.com/thatch/moreorless/";
    changelog = "https://github.com/thatch/moreorless/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
