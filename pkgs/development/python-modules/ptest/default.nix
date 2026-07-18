{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ptest";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "KarlGong";
    repo = "ptest";
    tag = "${version}-release";
    hash = "sha256-lmiBqFWGfYdsBXCh6dQ9xed+HhpP6PWa9Csr68GtLxs=";
  };

  # I don't know how to run the tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ptest" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "(.*)-release"
    ];
  };

  meta = {
    description = "Test classes and test cases using decorators, execute test cases by command line, and get clear reports";
    homepage = "https://pypi.org/project/ptest/";
    license = lib.licenses.asl20;
    mainProgram = "ptest";
  };
}
