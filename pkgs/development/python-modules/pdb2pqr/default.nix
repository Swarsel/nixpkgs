{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  hatchling,
  mmcif-pdbx,
  numpy,
  pandas,
  propka,
  pytestCheckHook,
  requests,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "pdb2pqr";
  version = "3.7.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BbXEZAIqOtEclZfG/H9wxWBhxGabFJelGVjakNlZFS8=";
  };

  propagatedBuildInputs = [
    mmcif-pdbx
    numpy
    propka
    requests
    docutils
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pandas
    testfixtures
  ];

  build-system = [
    hatchling
  ];

  disabledTests = [
    # these tests have network access
    "test_short_pdb"
    "test_basic_cif"
    "test_long_pdb"
    "test_ligand_biomolecule"
    "test_log_output_in_pqr_location"
    "test_propka_apo"
    "test_propka_pka"
    "test_basic"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pdb2pqr" ];
  pythonRelaxDeps = [ "docutils" ];

  meta = {
    description = "Software for determining titration states, adding missing atoms, and assigning charges/radii to biomolecules";
    homepage = "https://www.poissonboltzmann.org/";
    changelog = "https://github.com/Electrostatics/pdb2pqr/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
