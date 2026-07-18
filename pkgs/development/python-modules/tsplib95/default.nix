{
  # Basic
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # Dependencies
  click,
  deprecated,
  networkx,
  # Test
  pytestCheckHook,
  # Build system
  setuptools,
  tabulate,
}:

buildPythonPackage rec {
  pname = "tsplib95";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "rhgrant10";
    repo = "tsplib95";
    tag = "v${version}";
    hash = "sha256-rDKnfuauA9+mlgL6Prfz0uRP2rWxiQruXBj422/6Eak=";
  };

  # Remove deprecated pytest-runner
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'," ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    deprecated
    networkx
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "tsplib95" ];

  pythonRelaxDeps = [
    "deprecated"
    "networkx"
    "tabulate"
  ];

  meta = {
    description = "Library for working with TSPLIB 95 files";
    homepage = "https://github.com/rhgrant10/tsplib95";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thattemperature ];
    mainProgram = "tsplib95";
  };
}
