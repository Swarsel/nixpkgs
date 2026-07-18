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
  pname = "dissect-ffs";
  version = "3.12";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.ffs";
    tag = version;
    hash = "sha256-U/Roo1+viW/Fnvt+QV6Rt6YvOSyOSGg5c2ZaHfaFQLQ=";
  };

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
  pythonImportsCheck = [ "dissect.ffs" ];

  meta = {
    description = "Dissect module implementing a parser for the FFS file system";
    homepage = "https://github.com/fox-it/dissect.ffs";
    changelog = "https://github.com/fox-it/dissect.ffs/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
