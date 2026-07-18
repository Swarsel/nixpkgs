{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  jinja2,
  poetry-core,
  pytestCheckHook,
  terminaltables,
}:

buildPythonPackage rec {
  pname = "envs";
  version = "1.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nYQ1xphdHN1oKZ4ExY4r24rmz2ayWWqAeeb5qT8qA5g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    click
    jinja2
    terminaltables
  ];

  disabledTests = [ "test_list_envs" ];
  enabledTestPaths = [ "envs/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "envs" ];

  meta = {
    description = "Easy access to environment variables from Python";
    homepage = "https://github.com/capless/envs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "envs";
  };
}
