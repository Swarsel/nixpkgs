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
  pname = "dissect-xfs";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.xfs";
    tag = version;
    hash = "sha256-dFM/xYJR3wBvOe/8rLJz4AK2jmp67T5vo/4TCMRSXzw=";
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
  pythonImportsCheck = [ "dissect.xfs" ];

  meta = {
    description = "Dissect module implementing a parser for the XFS file system";
    homepage = "https://github.com/fox-it/dissect.xfs";
    changelog = "https://github.com/fox-it/dissect.xfs/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
