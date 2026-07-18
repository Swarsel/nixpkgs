{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytest-benchmark,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "jsonpath-python";
  version = "1.1.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3e2ZMrTsQfuHJuCcg6+k5r5hj5OMLbKHzCqBcjxjlnE=";
    pname = "jsonpath_python";
  };

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
  ]
  ++ pytest-benchmark.optional-dependencies.histogram;

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "jsonpath" ];

  meta = {
    description = "More powerful JSONPath implementations in modern python";
    homepage = "https://github.com/sean2077/jsonpath-python";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ dadada ];
  };
}
