{
  lib,
  buildPythonPackage,
  drawio-headless,
  fetchPypi,
  livereload,
  mkdocs,
  poetry-core,
  tornado,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-drawio-exporter";
  version = "0.10.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LbHnV6WLIgab6CrripZnnqc5kkVyF4E+Ls00h1bXjHc=";
    pname = "mkdocs_drawio_exporter";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    mkdocs
    drawio-headless
    livereload
    tornado
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_drawio_exporter" ];

  meta = {
    description = "Module for exporting Draw.io diagrams";

    longDescription = ''
      Exports your Draw.io diagrams at build time for easier embedding into your documentation.
    '';

    homepage = "https://github.com/LukeCarrier/mkdocs-drawio-exporter/";
    changelog = "https://github.com/LukeCarrier/mkdocs-drawio-exporter/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ snpschaaf ];
  };
}
