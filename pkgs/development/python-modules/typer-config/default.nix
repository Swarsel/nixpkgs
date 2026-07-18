{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pydantic,
  pytestCheckHook,
  python-dotenv,
  pyyaml,
  schema,
  toml,
  typer,
  uv-build,
}:

buildPythonPackage rec {
  pname = "typer-config";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "maxb2";
    repo = "typer-config";
    tag = version;
    hash = "sha256-pR32E6zdlfNpzIS4u/WOCxuqrnjDWZYiroUu92RBHVM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.7.19,<0.8.0" "uv_build"
  '';

  nativeCheckInputs = [
    pydantic
    pytestCheckHook
    schema
  ]
  ++ lib.flatten (builtins.attrValues optional-dependencies);

  build-system = [ uv-build ];
  dependencies = [ typer ];

  disabledTestPaths = [
    # Don't test the example
    "tests/test_example.py"
  ];

  optional-dependencies = {
    all = [
      python-dotenv
      pyyaml
      toml
    ];

    python-dotenv = [ python-dotenv ];
    toml = [ toml ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "typer_config" ];

  meta = {
    description = "Utilities for working with configuration files in typer CLIs";
    homepage = "https://github.com/maxb2/typer-config";
    changelog = "https://github.com/maxb2/typer-config/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
