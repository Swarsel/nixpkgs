{
  lib,
  buildPythonPackage,
  fetchPypi,
  plotext,
  poetry-core,
  textual,
}:

buildPythonPackage rec {
  pname = "textual-plotext";
  version = "1.0.1";

  # GitHub is missing tags: https://github.com/Textualize/textual-plotext/issues/18
  src = fetchPypi {
    inherit version;
    hash = "sha256-g29TozFnVmCeGUEpo1wodWOOeVjCYfVB4KeU98mAEb4=";
    pname = "textual_plotext";
  };

  build-system = [ poetry-core ];

  dependencies = [
    plotext
    textual
  ];

  pyproject = true;
  pythonImportsCheck = [ "textual_plotext" ];

  meta = {
    description = "Textual widget wrapper for the Plotext plotting library";
    homepage = "https://github.com/Textualize/textual-plotext";
    changelog = "https://github.com/Textualize/textual-plotext/blob/main/ChangeLog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ andersk ];
  };
}
