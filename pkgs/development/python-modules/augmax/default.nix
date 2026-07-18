{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  einops,
  jax,
  jaxlib,
  setuptools,
}:

buildPythonPackage rec {
  pname = "augmax";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "khdlr";
    repo = "augmax";
    tag = "v${version}";
    hash = "sha256-FXgkhZEAR1Y2LvVvV+IWMSQDWrLulLDsSKKuw4ER5wg=";
  };

  # augmax does not have any tests at the time of writing (2022-02-19), but
  # jaxlib is necessary for the pythonImportsCheckPhase.
  nativeCheckInputs = [ jaxlib ];
  build-system = [ setuptools ];

  dependencies = [
    einops
    jax
  ];

  pyproject = true;
  pythonImportsCheck = [ "augmax" ];

  meta = {
    description = "Efficiently Composable Data Augmentation on the GPU with Jax";
    homepage = "https://github.com/khdlr/augmax";
    changelog = "https://github.com/khdlr/augmax/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ samuela ];
  };
}
