{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pretix-plugin-build,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pretix-payone";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-payone";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ru944WkeNBYq5XkIMoAFLgGcU2gGxClEYVhCwuZGioI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_payone"
  ];

  meta = {
    description = "Pretix payment plugin for PAYONE";
    homepage = "https://github.com/pretix/pretix-payone";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
