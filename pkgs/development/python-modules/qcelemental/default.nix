{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  networkx,
  numpy,
  packaging,
  pint,
  poetry-core,
  pydantic,
  pytestCheckHook,
  pythonAtLeast,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "qcelemental";
  version = "0.50.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jVOCbTP/FXyqL1yJbBkxHPPJ2vcZyrjG+GBg+V1fdEs=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    poetry-core
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    packaging
    pint
    pydantic
  ];

  # These tests require network access
  disabledTestPaths = [
    "qcelemental/tests/test_gph_uno_bipartite.py"
    "qcelemental/tests/test_model_general.py"
    "qcelemental/tests/test_model_results.py"
    "qcelemental/tests/test_molecule.py"
    "qcelemental/tests/test_molparse_align_chiral.py"
    "qcelemental/tests/test_molparse_from_schema.py"
    "qcelemental/tests/test_molparse_from_string.py"
    "qcelemental/tests/test_molparse_pubchem.py"
    "qcelemental/tests/test_molparse_to_schema.py"
    "qcelemental/tests/test_molparse_to_string.py"
    "qcelemental/tests/test_molutil.py"
    "qcelemental/tests/test_utils.py"
    "qcelemental/tests/test_zqcschema.py"
  ];

  optional-dependencies = {
    align = [
      networkx
      scipy
    ];

    viz = [
      # TODO: nglview
      ipykernel
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "qcelemental" ];

  meta = {
    description = "Periodic table, physical constants and molecule parsing for quantum chemistry";
    homepage = "https://github.com/MolSSI/QCElemental";
    changelog = "https://github.com/MolSSI/QCElemental/blob/v${version}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sheepforce ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
