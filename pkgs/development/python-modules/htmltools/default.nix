{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pytestCheckHook,
  setuptools,
  syrupy,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "htmltools";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = "py-htmltools";
    tag = "v${version}";
    hash = "sha256-psrTSy4NhhsZamB7lQDt+n6LUDiRcHD5+FFqTIIrnZc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    syrupy
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    packaging
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "htmltools" ];

  meta = {
    description = "Tools for HTML generation and output";
    homepage = "https://github.com/posit-dev/py-htmltools";
    changelog = "https://github.com/posit-dev/py-htmltools/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
