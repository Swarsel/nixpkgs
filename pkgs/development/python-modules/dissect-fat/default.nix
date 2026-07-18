{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-fat";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.fat";
    tag = version;
    hash = "sha256-BxxC+ebD8xYrBVuYmXdxPcU2JDJgWAtEBlVGqE8oVec=";
  };

  # dissect.fat.exceptions.InvalidBPB: Invalid BS_jmpBoot
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.fat" ];

  meta = {
    description = "Dissect module implementing a parser for the FAT file system";
    homepage = "https://github.com/fox-it/dissect.fat";
    changelog = "https://github.com/fox-it/dissect.fat/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
