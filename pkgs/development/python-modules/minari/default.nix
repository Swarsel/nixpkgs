{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-cloud-storage,
  # dependencies
  gymnasium,
  h5py,
  huggingface-hub,
  jax,
  # tests
  jaxlib,
  mktestdocs,
  numpy,
  packaging,
  # optional-dependencies
  pyarrow,
  pytest,
  pytestCheckHook,
  scikit-image,
  # build-system
  setuptools,
  tqdm,
  typer,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "minari";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "Farama-Foundation";
    repo = "Minari";
    tag = "v${version}";
    hash = "sha256-LvJwp2dZdGPazJPWQtrk+v7zaPjOlomBu5j9avVdCcA=";
  };

  nativeCheckInputs = [
    jaxlib
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
  ];

  dependencies = [
    gymnasium
    numpy
    packaging
    typer
    typing-extensions
  ];

  disabledTestPaths = [
    # Require internet access
    "tests/dataset/test_dataset_download.py"
    "tests/test_cli.py"
  ];

  disabledTests = [
    # Require internet access
    "test_download_namespace_dataset"
    "test_download_namespace_metadata"
    "test_markdown"

    # Attempts at installing minari using pip (impossible in the sandbox)
    "test_readme"
  ];

  optional-dependencies = {
    arrow = [ pyarrow ];
    create = [ jax ];

    gcs = [
      google-cloud-storage
      tqdm
    ];

    hdf5 = [ h5py ];
    hf = [ huggingface-hub ];

    integrations = [
      # agilerl
      # d3rlpy
    ];

    testing = [
      # gymnasium-robotics
      mktestdocs
      pytest
      scikit-image
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "minari" ];

  meta = {
    description = "Standard format for offline reinforcement learning datasets, with popular reference datasets and related utilities";
    homepage = "https://github.com/Farama-Foundation/Minari";
    changelog = "https://github.com/Farama-Foundation/Minari/releases/tag/v${version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "minari";
  };
}
