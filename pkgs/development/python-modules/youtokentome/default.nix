{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  cython,
  setuptools,
  tabulate,
}:

buildPythonPackage rec {
  pname = "youtokentome";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "VKCOM";
    repo = "YouTokenToMe";
    tag = "v${version}";
    hash = "sha256-+GI752Ih7Ou1wyChR2y80BJmeTYdHWLPX6A1lvMyLGU=";
  };

  nativeBuildInputs = [
    cython
    setuptools
  ];

  propagatedBuildInputs = [
    click
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "youtokentome" ];

  meta = {
    description = "Unsupervised text tokenizer";
    homepage = "https://github.com/VKCOM/YouTokenToMe";
    changelog = "https://github.com/VKCOM/YouTokenToMe/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "yttm";
  };
}
