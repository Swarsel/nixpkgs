{
  lib,
  blockbuster,
  buildPythonPackage,
  croniter,
  fetchPypi,
  hatchling,
  langgraph,
  langgraph-checkpoint,
  sse-starlette,
  starlette,
  structlog,
}:

buildPythonPackage (finalAttrs: {
  pname = "langgraph-runtime-inmem";
  version = "0.30.0";

  # Not available in any repository
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-MZVOHebNQ8KEtCUkPU+uroGPaLPayk2+QxPmUbb14R0=";
    pname = "langgraph_runtime_inmem";
  };

  # no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    blockbuster
    croniter
    langgraph
    langgraph-checkpoint
    sse-starlette
    starlette
    structlog
  ];

  pyproject = true;
  pythonImportsCheck = [ "langgraph_runtime_inmem" ];

  meta = {
    description = "Inmem implementation for the LangGraph API server";
    homepage = "https://pypi.org/project/langgraph-runtime-inmem/";
    # no changelog
    license = lib.licenses.elastic20;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
