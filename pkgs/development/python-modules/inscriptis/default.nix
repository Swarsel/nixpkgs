{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fastapi,
  hatchling,
  httpx,
  lxml,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "inscriptis";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "weblyzard";
    repo = "inscriptis";
    tag = version;
    hash = "sha256-hNNPY2/SroVQnf04SJ/2yYorBgQJk6d0X616+w41Y1c=";
  };

  nativeCheckInputs = [
    fastapi
    httpx
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];

  dependencies = [
    lxml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "inscriptis" ];
  pythonRelaxDeps = [ "lxml" ];

  meta = {
    description = "HTML to text converter";
    homepage = "https://github.com/weblyzard/inscriptis";
    changelog = "https://github.com/weblyzard/inscriptis/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "inscript.py";
  };
}
