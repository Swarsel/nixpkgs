{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  hatch-vcs,
  hatchling,
  numpy,
  pytestCheckHook,
  uhi,
}:

buildPythonPackage rec {
  pname = "histoprint";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "scikit-hep";
    repo = "histoprint";
    tag = "v${version}";
    hash = "sha256-qMg0Ct39BjdcyWB3KxG74rVqVW4I0DGZ5GS7D3uYq3w=";
  };

  checkInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    click
    numpy
    uhi
  ];

  pyproject = true;

  meta = {
    description = "Pretty print histograms to the console";
    homepage = "https://github.com/scikit-hep/histoprint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
    mainProgram = "histoprint";
  };
}
