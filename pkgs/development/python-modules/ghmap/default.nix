{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "ghmap";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "sgl-umons";
    repo = "ghmap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FXeLSCoZRkHVXDtV/L75mACdU3MvOOSe3Cw6U2+6FfE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ghmap"
  ];

  meta = {
    description = "A Python tool for mapping GitHub events to contributor activities";
    homepage = "https://github.com/sgl-umons/ghmap";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
