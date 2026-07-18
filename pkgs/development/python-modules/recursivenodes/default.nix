{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "recursivenodes";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "tisaac";
    repo = "recursivenodes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RThTrYxM4dvTclUZrnne1q1ij9k6aJEeYKTZaxqzs5g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "recursivenodes" ];

  meta = {
    description = "Recursive, parameter-free, explicitly defined interpolation nodes for simplices";
    homepage = "https://tisaac.gitlab.io/recursivenodes/";
    changelog = "https://gitlab.com/tisaac/recursivenodes/-/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://gitlab.com/tisaac/recursivenodes";
  };
})
