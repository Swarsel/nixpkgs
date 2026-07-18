{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  mkdocs,
  platformdirs,
  wcmatch,
}:

buildPythonPackage rec {
  pname = "mkdocs-include-markdown-plugin";
  version = "7.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-KAASZ0ZFLjHC4yG71DyBkLNW4N41PiDLwWo0o8PWeWw=";
    pname = "mkdocs_include_markdown_plugin";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    mkdocs
    wcmatch
  ];

  optional-dependencies = {
    cache = [
      platformdirs
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_include_markdown_plugin"
  ];

  meta = {
    description = "Mkdocs Markdown includer plugin";
    homepage = "https://pypi.org/project/mkdocs-include-markdown-plugin/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      e1mo
      xanderio
    ];
  };
}
