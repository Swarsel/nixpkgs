{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pysigma,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysigma-backend-elasticsearch";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "SigmaHQ";
    repo = "pySigma-backend-elasticsearch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eSf0uhjhO1Bc63EBy505tTGASTNJ/mK0943vBXAT9As=";
  };

  # Starting with 2.0.0 all tests require network access
  doCheck = false;

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    requests
    writableTmpDirAsHomeHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ pysigma ];
  pyproject = true;

  #pythonImportsCheck = [ "sigma.backends.elasticsearch" ];
  meta = {
    description = "Library to support Elasticsearch for pySigma";
    homepage = "https://github.com/SigmaHQ/pySigma-backend-elasticsearch";
    changelog = "https://github.com/SigmaHQ/pySigma-backend-elasticsearch/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
