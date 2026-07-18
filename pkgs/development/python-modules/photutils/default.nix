{
  lib,
  fetchFromGitHub,
  astropy,
  bottleneck,
  buildPythonPackage,
  cython,
  extension-helpers,
  gwcs,
  matplotlib,
  numpy,
  rasterio,
  scikit-image,
  scikit-learn,
  scipy,
  setuptools,
  setuptools-scm,
  shapely,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "photutils";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "photutils";
    tag = finalAttrs.version;
    hash = "sha256-jfmC3pAQa/PrdEUa7QSYGW5zWzX43ghYCpmgRYup/Ks=";
  };

  nativeBuildInputs = [
    cython
    extension-helpers
    numpy
  ];

  # With 1.12.0 tests have issues importing modules
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    astropy
    numpy
    scipy
  ];

  optional-dependencies = {
    all = [
      bottleneck
      gwcs
      matplotlib
      rasterio
      scikit-image
      scikit-learn
      shapely
      tqdm
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "photutils" ];

  meta = {
    description = "Astropy package for source detection and photometry";
    homepage = "https://github.com/astropy/photutils";
    changelog = "https://github.com/astropy/photutils/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
