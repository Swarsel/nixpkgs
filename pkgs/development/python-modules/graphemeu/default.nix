{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "graphemeu";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "timendum";
    repo = "grapheme";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qDspbeOmlfQ4VLPdKEuxNPYilKjwUcAJiEOMfx9fFlI=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "grapheme"
  ];

  meta = {
    description = "Python package for grapheme aware string handling";
    homepage = "https://github.com/timendum/grapheme";
    changelog = "https://github.com/timendum/grapheme/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anthonyroussel ];
  };
})
