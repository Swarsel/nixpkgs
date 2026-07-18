{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  inline-snapshot,
  pytest,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "http-snapshot";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "karpetrosyan";
    repo = "http-snapshot";
    tag = finalAttrs.version;
    hash = "sha256-4roxtwzB3HXwvlBqjdHEit4flXlogVwzlYNgQE8vFwE=";
  };

  buildInputs = [
    pytest
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    inline-snapshot
  ];

  optional-dependencies = {
    httpx = [ httpx ];
    requests = [ requests ];
  };

  pyproject = true;

  pytestFlags = [
    "--inline-snapshot=disable"
  ];

  pythonImportsCheck = [ "http_snapshot" ];

  meta = {
    description = "Pytest plugin that snapshots requests made with popular Python HTTP clients";
    homepage = "https://github.com/karpetrosyan/http-snapshot";
    changelog = "https://github.com/karpetrosyan/http-snapshot/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
