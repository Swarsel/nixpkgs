{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  binaryornot,
  boolean-py,
  buildPythonPackage,
  click,
  # test dependencies
  freezegun,
  furo,
  jinja2,
  license-expression,
  myst-parser,
  pbr,
  poetry-core,
  pytestCheckHook,
  python-debian,
  python-magic,
  sphinxHook,
  sphinxcontrib-apidoc,
  tomlkit,
}:

buildPythonPackage rec {
  pname = "reuse";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "fsfe";
    repo = "reuse-tool";
    tag = "v${version}";
    hash = "sha256-J49RIt7MxnsMJqJAaGvYgUzXMHAT9/frMmrkhWXe5tQ=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    freezegun
  ];

  build-system = [
    poetry-core
    sphinxHook
    furo
    myst-parser
    pbr
    sphinxcontrib-apidoc
  ];

  dependencies = [
    attrs
    binaryornot
    boolean-py
    click
    python-debian
    jinja2
    license-expression
    python-magic
    tomlkit
  ];

  disabledTestPaths = [
    # pytest wants to execute the actual source files for some reason, which fails with ImportPathMismatchError()
    "src/reuse"
  ];

  pyproject = true;
  pythonImportsCheck = [ "reuse" ];

  sphinxBuilders = [
    "html"
    "man"
  ];

  sphinxRoot = "docs";

  meta = {
    description = "Tool for compliance with the REUSE Initiative recommendations";
    homepage = "https://github.com/fsfe/reuse-tool";
    changelog = "https://github.com/fsfe/reuse-tool/blob/v${version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      cc-by-sa-40
      cc0
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [
      FlorianFranzen
      Luflosi
    ];

    mainProgram = "reuse";
  };
}
