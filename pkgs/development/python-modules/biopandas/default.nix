{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  looseversion,
  mmtf-python,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "biopandas";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "BioPandas";
    repo = "biopandas";
    tag = "v${version}";
    hash = "sha256-dUeGjDDz9VA1NrFLGKy0ebaa+MU4c1tHi5YYkAspLRk=";
  };

  postPatch = ''
    substituteInPlace biopandas/mmtf/pandas_mmtf.py --replace-fail \
      'int(np.argwhere(np.array(model_indices) > ch_idx)[0]) + 1' \
      'int(np.argwhere(np.array(model_indices) > ch_idx)[0][0]) + 1'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    pandas
    mmtf-python
    looseversion
  ];

  disabledTests = [
    # require network access
    "test_mmcif_pdb_conversion"
    "test_fetch_pdb"
    "test_write_mmtf_bp"
    "test_write_mmtf"
    "test_b_factor_shift"
  ];

  pyproject = true;
  pythonImportsCheck = [ "biopandas" ];
  pythonRelaxDeps = [ "looseversion" ];

  meta = {
    description = "Working with molecular structures in pandas DataFrames";
    homepage = "https://github.com/BioPandas/biopandas";
    changelog = "https://github.com/BioPandas/biopandas/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
