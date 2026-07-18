{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  numpy,
  poetry-core,
  pytestCheckHook,
  pyyaml,
  sphinx,
}:

buildPythonPackage (finalAttrs: {
  pname = "fica";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "chrispyles";
    repo = "fica";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A13xC8BGsPddsk8ZN2DeMCYc0phy/B4JD9shuoorOwg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numpy
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    docutils
    pyyaml
    sphinx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fica"
  ];

  meta = {
    description = "Library for managing and documenting user configurations";
    homepage = "https://github.com/chrispyles/fica";
    changelog = "https://github.com/chrispyles/fica/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hhr2020 ];
  };
})
