{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "simple-term-menu";
  version = "1.6.6";

  src = fetchFromGitHub {
    owner = "IngoMeyer441";
    repo = "simple-term-menu";
    tag = "v${version}";
    hash = "sha256-nfMqtyUalt/d/wTyRUlu5x4Q349ARY8hDMi8Ui4cTI4=";
  };

  nativeBuildInputs = [ setuptools ];
  # no unit tests in the upstream
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "simple_term_menu" ];

  meta = {
    description = "Python package which creates simple interactive menus on the command line";
    homepage = "https://github.com/IngoMeyer441/simple-term-menu";
    changelog = "https://github.com/IngoMeyer441/simple-term-menu/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ smrehman ];
    mainProgram = "simple-term-menu";
  };
}
