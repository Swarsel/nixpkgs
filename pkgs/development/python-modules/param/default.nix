{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  # build-system
  hatchling,
  # tests
  numpy,
  pandas,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "param";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "holoviz";
    repo = "param";
    tag = "v${version}";
    hash = "sha256-BqZ4HbYVdmgyOacwzmSia7GinMqz3k6pLyElbST3NTY=";
  };

  nativeCheckInputs = [
    numpy
    pandas
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "param" ];

  meta = {
    description = "Declarative Python programming using Parameters";
    homepage = "https://param.holoviz.org/";
    changelog = "https://github.com/holoviz/param/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
