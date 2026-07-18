{
  lib,
  buildPythonPackage,
  deprecated,
  fetchPypi,
  hatchling,
  pydantic,
}:

buildPythonPackage rec {
  pname = "llama-index-instrumentation";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-7rckZIsl0UneiCpayeIcWssc54DaIUvaKwdTQa8prY4=";
    pname = "llama_index_instrumentation";
  };

  build-system = [ hatchling ];

  dependencies = [
    deprecated
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "llama_index_instrumentation" ];
  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Support for instrumentation in LlamaIndex applications";
    homepage = "https://pypi.org/project/llama-index-instrumentation/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
