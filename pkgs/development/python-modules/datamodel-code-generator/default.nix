{
  lib,
  fetchFromGitHub,
  argcomplete,
  black,
  buildPythonPackage,
  genson,
  graphql-core,
  hatch-vcs,
  hatchling,
  httpx,
  inflect,
  inline-snapshot,
  isort,
  jinja2,
  openapi-spec-validator,
  packaging,
  prance,
  pydantic,
  pysnooper,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  ruff,
  time-machine,
  watchfiles,
}:

buildPythonPackage rec {
  pname = "datamodel-code-generator";
  version = "0.55.0";

  src = fetchFromGitHub {
    owner = "koxudaxi";
    repo = "datamodel-code-generator";
    tag = version;
    hash = "sha256-zsLJv7gKhmnEIS/AUvnBzm+07QFQoMdiFo/PkfRyHek=";
  };

  nativeCheckInputs = [
    inline-snapshot
    pytest-mock
    pytestCheckHook
    time-machine
  ]
  ++ optional-dependencies.all;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    argcomplete
    black
    genson
    inflect
    isort
    jinja2
    packaging
    pydantic
    pyyaml
  ];

  disabledTests = [
    # remote testing, name resolution failure.
    "test_openapi_parser_parse_remote_ref"
  ];

  optional-dependencies = {
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);
    debug = [ pysnooper ];
    graphql = [ graphql-core ];
    http = [ httpx ];
    ruff = [ ruff ];

    validation = [
      openapi-spec-validator
      prance
    ];

    watch = [
      watchfiles
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "datamodel_code_generator" ];

  pythonRelaxDeps = [
    "inflect"
    "isort"
  ];

  meta = {
    description = "Pydantic model and dataclasses.dataclass generator for easy conversion of JSON, OpenAPI, JSON Schema, and YAML data sources";
    homepage = "https://github.com/koxudaxi/datamodel-code-generator";
    changelog = "https://github.com/koxudaxi/datamodel-code-generator/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tochiaha ];
    mainProgram = "datamodel-code-generator";
  };
}
