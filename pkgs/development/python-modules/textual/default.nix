{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  jinja2,
  # dependencies
  markdown-it-py,
  mdit-py-plugins,
  platformdirs,
  # build-system
  poetry-core,
  pytest-aiohttp,
  pytest-xdist,
  pytestCheckHook,
  rich,
  syrupy,
  time-machine,
  # optional-dependencies
  tree-sitter,
  tree-sitter-c-sharp,
  tree-sitter-html,
  tree-sitter-javascript,
  tree-sitter-make,
  tree-sitter-markdown,
  tree-sitter-python,
  tree-sitter-rust,
  tree-sitter-sql,
  tree-sitter-yaml,
  tree-sitter-zeek,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "textual";
  version = "8.2.8";

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "textual";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4T+/eD0adPugDP7TCDoDaOe0OrEFskCUadLVEixmTwo=";
  };

  nativeCheckInputs = [
    jinja2
    pytest-aiohttp
    pytest-xdist
    pytestCheckHook
    syrupy
    time-machine
    tree-sitter
    tree-sitter-markdown
    tree-sitter-python
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ poetry-core ];

  dependencies = [
    markdown-it-py
    mdit-py-plugins
    platformdirs
    rich
    typing-extensions
  ]
  ++ markdown-it-py.optional-dependencies.plugins
  ++ markdown-it-py.optional-dependencies.linkify;

  disabledTestPaths = [
    # Snapshot tests require syrupy<4
    "tests/snapshot_tests/test_snapshots.py"
  ];

  disabledTests = [
    # Assertion issues
    "test_textual_env_var"

    # fixture 'snap_compare' not found
    "test_progress_bar_width_1fr"
  ];

  optional-dependencies = {
    syntax = [
      tree-sitter
      tree-sitter-c-sharp
      tree-sitter-html
      tree-sitter-javascript
      tree-sitter-make
      tree-sitter-markdown
      tree-sitter-python
      tree-sitter-rust
      tree-sitter-sql
      tree-sitter-yaml
      tree-sitter-zeek
    ];
  };

  pyproject = true;

  pytestFlags = [
    # Some tests in groups require state from previous tests
    # See https://github.com/Textualize/textual/issues/4924#issuecomment-2304889067
    "--dist=loadgroup"
  ];

  pythonImportsCheck = [ "textual" ];

  pythonRelaxDeps = [
    "rich"
  ];

  meta = {
    description = "TUI framework for Python inspired by modern web development";
    homepage = "https://github.com/Textualize/textual";
    changelog = "https://github.com/Textualize/textual/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gepbird ];
  };
})
