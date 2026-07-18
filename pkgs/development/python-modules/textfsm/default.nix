{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "textfsm";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "textfsm";
    tag = "v${version}";
    hash = "sha256-ygVcDdT85mRN+qYfTZqraRVyp2JlLwwujBW1e/pPJNc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python module for parsing semi-structured text into python tables";
    homepage = "https://github.com/google/textfsm";
    changelog = "https://github.com/google/textfsm/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "textfsm";
  };
}
