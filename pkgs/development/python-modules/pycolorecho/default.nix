{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycolorecho";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "coldsofttech";
    repo = "pycolorecho";
    rev = version;
    hash = "sha256-h/7Wi0x8iLMZpPYekK6W9LTM+2nYJTaKClNtRTzbmdg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pycolorecho" ];

  meta = {
    description = "Simple Python package for colorized terminal output";
    homepage = "https://github.com/coldsofttech/pycolorecho";
    changelog = "https://github.com/coldsofttech/pycolorecho/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ShamrockLee ];
  };
}
