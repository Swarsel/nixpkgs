{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  setuptools,
}:

buildPythonPackage rec {
  pname = "editorconfig";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "editorconfig";
    repo = "editorconfig-core-py";
    rev = "v${version}";
    hash = "sha256-3wEW2FMBKBS9mekYgmYG3Ohd3plCtYDFejwG3W6B9IA=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ cmake ];

  checkPhase = ''
    runHook preCheck

    cmake .
    ctest .

    runHook postCheck
  '';

  build-system = [ setuptools ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "editorconfig" ];

  meta = {
    description = "EditorConfig File Locator and Interpreter for Python";
    homepage = "https://github.com/editorconfig/editorconfig-core-py";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "editorconfig";
  };
}
