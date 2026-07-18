{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  prompt-toolkit,
  pygments,
  setuptools,
}:

buildPythonPackage {
  pname = "pypager";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "prompt-toolkit";
    repo = "pypager";
    rev = "0255d59a14ffba81c3842ef570c96c8dfee91e8e";
    hash = "sha256-uPpVAI12INKFZDiTQdzQ0dhWCBAGeu0488zZDEV22mU=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    prompt-toolkit
    pygments
  ];

  pyproject = true;
  pythonImportsCheck = [ "pypager" ];

  meta = {
    description = ''Pure Python pager (like "more" and "less")'';
    homepage = "https://github.com/prompt-toolkit/pypager";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ taha-yassine ];
    mainProgram = "pypager";
  };
}
