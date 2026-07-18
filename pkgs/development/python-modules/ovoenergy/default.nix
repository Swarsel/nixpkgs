{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  click,
  incremental,
  pyjwt,
  setuptools,
  typer,
}:

buildPythonPackage rec {
  pname = "ovoenergy";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "timmo001";
    repo = "ovoenergy";
    tag = version;
    hash = "sha256-oWJxpiC83C/ghs/Ik8+DrPWtP/j5jWEZ3+9Nqg4ARKU=";
  };

  nativeBuildInputs = [ incremental ];
  # Project has no tests
  doCheck = false;

  build-system = [
    incremental
    setuptools
  ];

  dependencies = [
    aiohttp
    click
    pyjwt
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "ovoenergy" ];

  meta = {
    description = "Python client for getting data from OVO's API";
    homepage = "https://github.com/timmo001/ovoenergy";
    changelog = "https://github.com/timmo001/ovoenergy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
