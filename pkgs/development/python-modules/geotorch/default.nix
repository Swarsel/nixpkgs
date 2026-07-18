{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  torch,
}:

buildPythonPackage rec {
  pname = "geotorch";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "lezcano";
    repo = "geotorch";
    tag = version;
    hash = "sha256-mMVgN8ZmedSz5VxAAE7vdvmZXiP5y3GkO60o5hCSHn8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "geotorch" ];

  meta = {
    description = "Constrained optimization toolkit for PyTorch";
    homepage = "https://github.com/lezcano/geotorch";
    changelog = "https://github.com/lezcano/geotorch/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
