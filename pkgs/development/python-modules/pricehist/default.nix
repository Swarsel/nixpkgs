{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  cssselect,
  curlify,
  lxml,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
  requests,
  responses,
}:
buildPythonPackage (finalAttrs: {
  pname = "pricehist";
  version = "1.4.16";

  src = fetchFromGitLab {
    owner = "chrisberkhout";
    repo = "pricehist";
    tag = finalAttrs.version;
    hash = "sha256-klNelb25yfToGUHyFGxNCvCwLhgIeISW46WBWjBZPVA=";
  };

  nativeCheckInputs = [
    responses
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
    lxml
    cssselect
    curlify
  ];

  pyproject = true;
  pythonRelaxDeps = [ "lxml" ];

  meta = {
    description = "Command-line tool for fetching and formatting historical price data, with support for multiple data sources and output formats";
    homepage = "https://gitlab.com/chrisberkhout/pricehist";
    license = lib.licenses.mit;
    mainProgram = "pricehist";
  };
})
