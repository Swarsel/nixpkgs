{
  lib,
  fetchFromGitHub,
  # dependencies
  babel,
  buildPythonPackage,
  # build-system
  hatchling,
  jinja2,
  json5,
  jsonschema,
  jupyter-server,
  # optional-dependencies
  openapi-core,
  packaging,
  # tests
  pytest-jupyter,
  pytest-timeout,
  pytestCheckHook,
  requests,
  requests-mock,
  ruamel-yaml,
  strict-rfc3339,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyterlab-server";
  version = "2.28.0";

  src = fetchFromGitHub {
    owner = "jupyterlab";
    repo = "jupyterlab_server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/h25HBKt6maaxuZRK+VMVA0AqTZhQkDnGVDgBisQcCw=";
  };

  patches = [
    # oopenapi-core changed their API, which breaks jupyterlab-server
    ./fix-openapi-core-compat.patch
  ];

  nativeCheckInputs = [
    pytest-jupyter
    pytest-timeout
    pytestCheckHook
    requests-mock
    strict-rfc3339
    writableTmpDirAsHomeHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.openapi;

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    babel
    jinja2
    json5
    jsonschema
    jupyter-server
    packaging
    requests
  ];

  disabledTestPaths = [
    # require optional language pack packages for tests
    "tests/test_translation_api.py"
  ];

  optional-dependencies = {
    openapi = [
      openapi-core
      ruamel-yaml
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jupyterlab_server" ];

  meta = {
    description = "Set of server components for JupyterLab and JupyterLab like applications";
    homepage = "https://github.com/jupyterlab/jupyterlab_server";
    changelog = "https://github.com/jupyterlab/jupyterlab_server/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
})
