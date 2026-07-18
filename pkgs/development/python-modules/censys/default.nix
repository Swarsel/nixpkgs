{
  lib,
  fetchFromGitHub,
  argcomplete,
  backoff,
  buildPythonPackage,
  importlib-metadata,
  parameterized,
  poetry-core,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  requests-mock,
  responses,
  rich,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "censys";
  version = "2.2.19";

  src = fetchFromGitHub {
    owner = "censys";
    repo = "censys-python";
    tag = "v${version}";
    hash = "sha256-3eQtGCIKtjpDWfyrIEPZnA6xLMNl0cg61wh0nuwNwh4=";
  };

  nativeCheckInputs = [
    parameterized
    pytest-mock
    pytest-cov-stub
    pytestCheckHook
    requests-mock
    responses
    writableTmpDirAsHomeHook
  ];

  # The tests want to write a configuration file
  preCheck = ''
    mkdir -p $HOME
  '';

  build-system = [ poetry-core ];

  dependencies = [
    argcomplete
    backoff
    requests
    rich
    importlib-metadata
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # argparse usage prefix uses the actual prog (python3.14 -m pytest) instead of sys.argv[0]
    "test_default_help"
    "test_help"
    "test_search_help"
  ];

  pyproject = true;
  pythonImportsCheck = [ "censys" ];

  meta = {
    description = "Python API wrapper for the Censys Search Engine (censys.io)";
    homepage = "https://github.com/censys/censys-python";
    changelog = "https://github.com/censys/censys-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "censys";
  };
}
