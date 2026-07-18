{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  click,
  h11,
  hatchling,
  httptools,
  python-dotenv,
  pyyaml,
  uvloop,
  watchfiles,
  websockets,
}:

buildPythonPackage rec {
  pname = "uvicorn";
  version = "0.46.0";

  src = fetchFromGitHub {
    owner = "encode";
    repo = "uvicorn";
    tag = version;
    hash = "sha256-+21fEPLnH2nrwPCXNlRw7U1VcXdaUnNCeThTfzepQoY=";
  };

  outputs = [
    "out"
    "testsout"
  ];

  # check in passthru.tests.pytest to escape infinite recursion with httpx/httpcore
  doCheck = false;

  postInstall = ''
    mkdir $testsout
    cp -R tests $testsout/tests
  '';

  build-system = [ hatchling ];

  dependencies = [
    click
    h11
  ];

  optional-dependencies.standard = [
    httptools
    python-dotenv
    pyyaml
    uvloop
    watchfiles
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "uvicorn" ];

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Lightning-fast ASGI server";
    homepage = "https://www.uvicorn.org/";
    changelog = "https://github.com/encode/uvicorn/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ wd15 ];
    mainProgram = "uvicorn";
  };
}
