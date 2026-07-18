{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  nbtlib,
  # build-system
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "litemapy";
  version = "0.11.0b0";

  src = fetchFromGitHub {
    owner = "SmylerMC";
    repo = "litemapy";
    rev = "v${version}";
    hash = "sha256-jqJYiggAs/JA+CJ35HzpsIQA/5p8PRFkbmPlwJvTI28=";
  };

  propagatedBuildInputs = [
    nbtlib
    typing-extensions
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "litemapy" ];

  meta = {
    description = "Python library to read and edit Litematica's schematic file format";
    homepage = "https://github.com/SmylerMC/litemapy";
    changelog = "https://github.com/SmylerMC/litemapy/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      gdd
      kuflierl
    ];
  };
}
