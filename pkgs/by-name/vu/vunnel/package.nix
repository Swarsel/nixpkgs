{
  lib,
  fetchFromGitHub,
  git,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "vunnel";
  version = "0.62.1";

  src = fetchFromGitHub {
    owner = "anchore";
    repo = "vunnel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Np80Yj8zazMBgeHu27N97K543GmKw8gf9Muixu4WBVQ=";
    leaveDotGit = true;
  };

  nativeCheckInputs = [
    git
  ]
  ++ (with python3.pkgs; [
    jsonschema
    pytest-mock
    pytest-unordered
    pytestCheckHook
  ]);

  build-system = with python3.pkgs; [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies =
    with python3.pkgs;
    [
      click
      colorlog
      cvss
      defusedxml
      ijson
      importlib-metadata
      iso8601
      lxml
      mashumaro
      mergedeep
      oras
      orjson
      packageurl-python
      pytest-snapshot
      python-dateutil
      pyyaml
      requests
      sqlalchemy
      xsdata
      xxhash
      yardstick
      zstandard
    ]
    ++ xsdata.optional-dependencies.cli
    ++ xsdata.optional-dependencies.lxml
    ++ xsdata.optional-dependencies.soap;

  disabledTests = [
    # Compare output
    "test_status"
    # TypeError
    "test_parser"
    # Test require network access
    "test_rhel_provider_supports_ignore_hydra_errors"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vunnel" ];

  pythonRelaxDeps = [
    "defusedxml"
    "ijson"
    "importlib-metadata"
    "sqlalchemy"
    "websockets"
    "xsdata"
  ];

  meta = {
    description = "Tool for collecting vulnerability data from various sources";
    homepage = "https://github.com/anchore/vunnel";
    changelog = "https://github.com/anchore/vunnel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "vunnel";
  };
})
