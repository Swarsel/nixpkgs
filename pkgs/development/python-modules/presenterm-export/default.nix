{
  lib,
  ansi2html,
  buildPythonPackage,
  dataclass-wizard,
  fetchPypi,
  libtmux,
  setuptools,
  weasyprint,
}:

buildPythonPackage rec {
  pname = "presenterm-export";
  version = "0.2.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9TkZ52lA1l3PYs2DTgji0LDrG5kixnFffuMIfhILY1E=";
    pname = "presenterm_export";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    ansi2html
    libtmux
    weasyprint
    dataclass-wizard
  ];

  pyproject = true;
  pythonImportsCheck = [ "presenterm_export" ];
  pythonRelaxDeps = true;

  meta = {
    description = "PDF exporter for presenterm";
    homepage = "https://github.com/mfontanini/presenterm-export";
    changelog = "https://github.com/mfontanini/presenterm-export/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ shivaraj-bh ];
  };
}
