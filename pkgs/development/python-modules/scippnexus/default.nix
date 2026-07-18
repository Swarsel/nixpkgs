{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  h5py,
  # tests
  pytestCheckHook,
  scipp,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "scippnexus";
  version = "26.1.1";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "scippnexus";
    tag = finalAttrs.version;
    hash = "sha256-sff/LZFoNOcmoVeQkuHZNGPZS9RMV8QrXIlmJiFJCeI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    h5py
    scipp
    scipy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "scippnexus"
  ];

  meta = {
    description = "H5py-like utility for NeXus files with seamless scipp integration";
    homepage = "https://scipp.github.io/scippnexus/";
    changelog = "https://github.com/scipp/scippnexus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
