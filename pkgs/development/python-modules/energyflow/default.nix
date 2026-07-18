{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  h5py,
  # build-system
  hatch-vcs,
  hatchling,
  # optional-dependencies
  igraph,
  numpy,
  # tests
  pot,
  pytestCheckHook,
  scikit-learn,
  tensorflow,
  tf-keras,
  wasserstein,
}:

buildPythonPackage (finalAttrs: {
  pname = "energyflow";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "pkomiske";
    repo = "EnergyFlow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4RzhpeOOty8IaVGByHD+PyeaeWgR7ZF98mSCJYoM9wY=";
  };

  nativeCheckInputs = [
    pot
    pytestCheckHook
    tf-keras
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    h5py
    numpy
    wasserstein
  ];

  disabledTests = [
    # Issues with array
    "test_emd_equivalence"
    "test_gdim"
    "test_n_jobs"
    "test_periodic_phi"

    # NameError: name '_distance_wrap' is not defined
    "test_emd_byhand_1_1"
    "test_emd_return_flow"
    "test_emde"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # RuntimeError: EMDStatus - Infeasible
    "test_emd_byhand_1_1"
    "test_emd_return_flow"
    "test_emde"
  ];

  optional-dependencies = {
    all = [
      igraph
      scikit-learn
      tensorflow
    ];

    archs = [
      scikit-learn
      tensorflow
    ];

    generation = [ igraph ];
  };

  pyproject = true;
  pythonImportsCheck = [ "energyflow" ];

  meta = {
    description = "Python package for the EnergyFlow suite of tools";
    homepage = "https://energyflow.network/";
    changelog = "https://github.com/thaler-lab/EnergyFlow/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
