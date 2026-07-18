{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-extfs";
  version = "3.15";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.extfs";
    tag = version;
    hash = "sha256-Ffm4AT5PLqlIOq6kxPcwqzRHNXP0tQ5tvkMS7dv9fZ4=";
  };

  # Archive files seems to be corrupt
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.extfs" ];

  meta = {
    description = "Dissect module implementing a parser for the ExtFS file system";
    homepage = "https://github.com/fox-it/dissect.extfs";
    changelog = "https://github.com/fox-it/dissect.extfs/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
