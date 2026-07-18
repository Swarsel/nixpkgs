{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyyaml,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "markdown";
  version = "3.10.2";

  src = fetchFromGitHub {
    owner = "Python-Markdown";
    repo = "markdown";
    tag = version;
    hash = "sha256-iZ+52xXtpn59HIcG2LTHHV0AMAz5N72np6s8+EOy8MQ=";
  };

  nativeCheckInputs = [
    unittestCheckHook
    pyyaml
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "markdown" ];

  meta = {
    description = "Python implementation of John Gruber's Markdown";
    homepage = "https://github.com/Python-Markdown/markdown";
    changelog = "https://github.com/Python-Markdown/markdown/blob/${src.tag}/docs/changelog.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "markdown_py";
  };
}
