{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  glibcLocales,
  lxml,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "junitparser";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "weiwei";
    repo = "junitparser";
    tag = version;
    hash = "sha256-I/bQQPT6b6PTZ9bIlWCQmN/gUWnVIO42xtJh/g7L79A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    lxml
    glibcLocales
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Manipulates JUnit/xUnit Result XML files";
    homepage = "https://github.com/weiwei/junitparser";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ multun ];
    mainProgram = "junitparser";
  };
}
