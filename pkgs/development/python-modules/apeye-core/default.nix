{
  lib,
  buildPythonPackage,
  domdf-python-tools,
  fetchPypi,
  hatch-requirements-txt,
  hatchling,
  idna,
}:
buildPythonPackage rec {
  pname = "apeye-core";
  version = "1.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Xecu09AMybIP6lXlS3q49e+FAOszpTaLwWKlWF4jilU=";
    pname = "apeye_core";
  };

  nativeBuildInputs = [
    hatch-requirements-txt
  ];

  build-system = [ hatchling ];

  dependencies = [
    domdf-python-tools
    idna
  ];

  pyproject = true;

  meta = {
    description = "Core (offline) functionality for the apeye library";
    homepage = "https://github.com/domdfcoding/apyey-core";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
