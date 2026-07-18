{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  hydrus,
  markdown,
  mkdocs-material,
  mkdocs-mermaid2-plugin,
  # for passthru.tests
  mkdocstrings,
  pygments,
  pytestCheckHook,
  pyyaml,
}:

let
  extensions = [
    "arithmatex"
    "b64"
    "betterem"
    "caret"
    "critic"
    "details"
    "emoji"
    "escapeall"
    "extra"
    "highlight"
    "inlinehilite"
    "keys"
    "magiclink"
    "mark"
    "pathconverter"
    "progressbar"
    "saneheaders"
    "smartsymbols"
    "snippets"
    "striphtml"
    "superfences"
    "tabbed"
    "tasklist"
    "tilde"
  ];
in
buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "10.21.3";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = "pymdown-extensions";
    tag = version;
    hash = "sha256-hu9fXjZxlris3AhPS7bz3kcSyQtSeh0B6ZAZBsCO4+g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [ hatchling ];

  dependencies = [
    markdown
    pygments
  ];

  pyproject = true;
  pythonImportsCheck = map (ext: "pymdownx.${ext}") extensions;

  passthru.tests = {
    inherit
      mkdocstrings
      mkdocs-material
      mkdocs-mermaid2-plugin
      hydrus
      ;
  };

  meta = {
    description = "Extensions for Python Markdown";
    homepage = "https://facelessuser.github.io/pymdown-extensions/";
    changelog = "https://github.com/facelessuser/pymdown-extensions/blob/${src.tag}/docs/src/markdown/about/changelog.md";

    license = with lib.licenses; [
      mit
      bsd2
    ];

    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
