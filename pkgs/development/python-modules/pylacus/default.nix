{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lookyloo-models,
  poetry-core,
  pydantic,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylacus";
  version = "1.25.0";

  src = fetchFromGitHub {
    owner = "ail-project";
    repo = "PyLacus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MmThqTPM5YvVFv4DBfTCVbbyjFvIaIUmbRci94F8ZQ0=";
  };

  # Tests require network access
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    lookyloo-models
    pydantic
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylacus" ];

  meta = {
    description = "Module to enqueue and query a remote Lacus instance";
    homepage = "https://github.com/ail-project/PyLacus";
    changelog = "https://github.com/ail-project/PyLacus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
