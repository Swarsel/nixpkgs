{
  lib,
  stdenv,
  astropy,
  buildPythonPackage,
  extension-helpers,
  fetchPypi,
  hypothesis,
  numpy,
  pytest-doctestplus,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "astropy-healpix";
  version = "1.1.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9SDYOr6CFdPo4aN7K9kRce42pvVfEQ1aLbhj112Bs7c=";
    pname = "astropy_healpix";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-doctestplus
    hypothesis
  ];

  # tests must be run in the build directory
  preCheck = ''
    cd build/lib*
  '';

  build-system = [
    extension-helpers
    numpy
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    astropy
  ];

  disabledTests = lib.optional (!stdenv.hostPlatform.isDarwin) "test_interpolate_bilinear_skycoord";
  pyproject = true;

  meta = {
    description = "BSD-licensed HEALPix for Astropy";
    homepage = "https://github.com/astropy/astropy-healpix";
    changelog = "https://github.com/astropy/astropy-healpix/blob/v${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.smaret ];
  };
})
