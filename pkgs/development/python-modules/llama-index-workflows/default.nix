{
  lib,
  buildPythonPackage,
  eval-type-backport,
  fetchPypi,
  llama-index-instrumentation,
  pydantic,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-index-workflows";
  version = "2.22.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-l7ZLz3LnfhoDgAaM2gnl0HdLdavbiRCWxDNobC8pnj4=";
    pname = "llama_index_workflows";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.10,<0.10.0" "uv_build"
  '';

  build-system = [ uv-build ];

  dependencies = [
    eval-type-backport
    llama-index-instrumentation
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "workflows" ];

  meta = {
    description = "Event-driven, async-first, step-based way to control the execution flow of AI applications like Agents";
    homepage = "https://pypi.org/project/llama-index-workflows/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
