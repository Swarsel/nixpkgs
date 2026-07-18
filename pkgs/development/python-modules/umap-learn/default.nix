{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  bokeh,
  buildPythonPackage,
  colorcet,
  dask,
  datashader,
  holoviews,
  matplotlib,
  # dependencies
  numba,
  numpy,
  pandas,
  pynndescent,
  # tests
  pytestCheckHook,
  scikit-image,
  scikit-learn,
  scipy,
  seaborn,
  # build-system
  setuptools,
  tensorflow,
  tensorflow-probability,
  tqdm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "umap-learn";
  version = "0.5.12";

  src = fetchFromGitHub {
    owner = "lmcinnes";
    repo = "umap";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-NORv3wJliKfft/+kMNKL133PKPN88Pt23yqbT1LjUKE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    numba
    numpy
    pynndescent
    scikit-learn
    scipy
    tqdm
  ];

  disabledTests = [
    # Plot functionality requires additional packages.
    # These test also fail with 'RuntimeError: cannot cache function' error.
    "test_plot_runs_at_all"
    "test_umap_plot_testability"
    "test_umap_update_large"

    # Flaky test. Fails with AssertionError sometimes.
    "test_sparse_hellinger"
    "test_densmap_trustworthiness_on_iris_supervised"

    # tensorflow maybe incompatible? https://github.com/lmcinnes/umap/issues/821
    "test_save_load"
  ];

  optional-dependencies = {
    parametric_umap = [
      tensorflow
      tensorflow-probability
    ];

    plot = [
      bokeh
      colorcet
      dask
      datashader
      holoviews
      matplotlib
      pandas
      scikit-image
      seaborn
    ];

    tbb = [
      # Not packaged.
      #tbb
    ];
  };

  pyproject = true;

  meta = {
    description = "Uniform Manifold Approximation and Projection";
    homepage = "https://github.com/lmcinnes/umap";
    changelog = "https://github.com/lmcinnes/umap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
