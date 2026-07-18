{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt-subcommands,
  future,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "eseries";
  version = "1.2.1-unstable-2023-12-17";

  src = fetchFromGitHub {
    owner = "rob-smallshire";
    repo = "eseries";
    rev = "3becd72de8b1b533b4a637169022231271a934fb"; # no tags
    hash = "sha256-iQBh4L+t24pOBh86wEqu5e6/RUmTQdCX+rOV/H2ywaY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [ setuptools ];

  dependencies = [
    docopt-subcommands
    future
  ];

  pyproject = true;
  pythonImportsCheck = [ "eseries" ];

  meta = {
    description = "Find value in the E-series used for electronic components values";
    homepage = "https://github.com/rob-smallshire/eseries";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "eseries";
  };
}
