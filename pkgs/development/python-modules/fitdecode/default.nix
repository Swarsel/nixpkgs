{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fitdecode";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "polyvertex";
    repo = "fitdecode";
    tag = "v${version}";
    hash = "sha256-3NoJHPql5mVQ+h2InM8tp7LIuR2znJyaawISarr688Q=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "fitdecode" ];

  meta = {
    description = "FIT file parsing and decoding library written in Python3";
    homepage = "https://github.com/polyvertex/fitdecode";
    changelog = "https://github.com/polyvertex/fitdecode/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tebriel ];
  };
}
