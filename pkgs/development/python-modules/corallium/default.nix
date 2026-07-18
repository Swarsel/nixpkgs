{
  lib,
  fetchFromGitHub,
  beartype,
  buildPythonPackage,
  poetry-core,
  pydantic,
  python,
  rich,
  tomli,
}:
buildPythonPackage rec {
  pname = "corallium";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "KyleKing";
    repo = "corallium";
    tag = version;
    hash = "sha256-0P8qmX+1zigL4jaA4TTuqAzFkyhQUfdGmPLxkFnT0qE=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    beartype
    pydantic
    rich
  ];

  pyproject = true;

  meta = {
    description = "Shared functionality for calcipy-ecosystem";
    homepage = "https://corallium.kyleking.me";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yajo ];
  };
}
