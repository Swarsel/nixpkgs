{
  lib,
  buildPythonPackage,
  click,
  click-option-group,
  fetchPypi,
  hatchling,
  importlib-metadata,
  isodate,
  progressbar2,
  pydicom,
  python-dateutil,
  pyyaml,
  requests,
  versioningit,
}:

buildPythonPackage rec {
  pname = "xnatpy";
  version = "0.8.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2hU+fUu058G+z/ecncQJd1D1b3e+9KpbnCxEb+VPWa0=";
    pname = "xnat";
  };

  # tests missing in PyPI dist and require network access and Docker container
  doCheck = false;

  build-system = [
    hatchling
    versioningit
  ];

  dependencies = [
    click
    click-option-group
    importlib-metadata
    isodate
    progressbar2
    pydicom
    python-dateutil
    pyyaml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "xnat" ];

  pythonRelaxDeps = [
    "importlib-metadata"
    "python-dateutil"
    "pydicom"
  ];

  meta = {
    description = "New XNAT client (distinct from pyxnat) that exposes XNAT objects/functions as Python objects/functions";
    homepage = "https://xnat.readthedocs.io";
    changelog = "https://gitlab.com/radiology/infrastructure/xnatpy/-/blob/${version}/CHANGELOG?ref_type=tags";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "xnat";
  };
}
