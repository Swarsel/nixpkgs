{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mdformat,
  mdformat-beautysh,
  mdformat-footnote,
  mdformat-front-matters,
  mdformat-gfm,
  mdformat-simple-breaks,
  mdit-py-plugins,
  more-itertools,
  pytest-snapshot,
  pytestCheckHook,
  # build-system
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "mdformat-mkdocs";
  version = "5.2.0b0";

  src = fetchFromGitHub {
    owner = "KyleKing";
    repo = "mdformat-mkdocs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d91XskyUFi7e/soC2fYN6FJUzOP8bZ+ZguLNNAxJC9c=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.10" "uv_build"
  '';

  nativeCheckInputs = [
    pytest-snapshot
    pytestCheckHook
  ];

  build-system = [
    uv-build
  ];

  dependencies = [
    mdformat
    mdformat-gfm
    mdit-py-plugins
    more-itertools
  ];

  disabledTestPaths = [
    # AssertionError: assert ParsedText(lines=[LineResult(parsed=ParsedLine(line_...
    "tests/format/test_parsed_result.py"
  ];

  optional-dependencies = {
    recommended = [
      mdformat-beautysh
      # mdformat-config
      mdformat-footnote
      mdformat-front-matters
      # mdformat-ruff
      mdformat-simple-breaks
      # mdformat-web
      # mdformat-wikilink
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mdformat_mkdocs" ];

  meta = {
    description = "Mdformat plugin for MkDocs";
    homepage = "https://github.com/KyleKing/mdformat-mkdocs";
    changelog = "https://github.com/KyleKing/mdformat-mkdocs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aldoborrero ];
  };
})
