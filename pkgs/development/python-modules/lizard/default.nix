{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  mock,
  pathspec, # for .gitignore support
  pygments, # for Erlang support
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lizard";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "terryyin";
    repo = "lizard";
    tag = version;
    hash = "sha256-rKCa5JniIr6SZaYgfC29GjOXl9MW9Dkt76z/oqfqnqc=";
  };

  propagatedBuildInputs = [
    jinja2
    pygments
    pathspec
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  disabledTestPaths = [
    # re.error: global flags not at the start of the expression at position 14
    "test/test_languages/testFortran.py"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "lizard" ];

  meta = {
    description = "Code analyzer without caring the C/C++ header files";
    homepage = "http://www.lizard.ws";
    changelog = "https://github.com/terryyin/lizard/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpetrucciani ];
    mainProgram = "lizard";
    downloadPage = "https://github.com/terryyin/lizard";
  };
}
