{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fonttools,
  pyparsing,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  ufo2ft,
  ufolib2,
}:

buildPythonPackage rec {
  pname = "vttlib";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "daltonmaag";
    repo = "vttLib";
    rev = "v${version}";
    hash = "sha256-m6oxJj6JEKo3HUMfKNIqHwOHNpuCkA0R8ZrY5HLsiKc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    ufo2ft
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fonttools
    pyparsing
    ufolib2
  ];

  pyproject = true;
  pythonImportsCheck = [ "vttLib" ];

  meta = {
    description = "Dump, merge and compile Visual TrueType data in UFO3 with FontTools";
    homepage = "https://github.com/daltonmaag/vttLib";
    changelog = "https://github.com/daltonmaag/vttLib/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
}
