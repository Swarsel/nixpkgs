{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  buildPythonPackage,
  glibc,
  libtiff,
  # dependencies
  lxml,
  numpy,
  openjpeg,
  pillow,
  pytestCheckHook,
  replaceVars,
  scikit-image,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "glymur";
  version = "0.14.7";

  src = fetchFromGitHub {
    owner = "quintusdias";
    repo = "glymur";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tcc37By5xukcN/C+RxA+B8fmFRlGQDl0aSkkT3zE9ws=";
  };

  patches = [
    (replaceVars ./set-lib-paths.patch {
      openjp2_lib = "${lib.getLib openjpeg}/lib/libopenjp2${stdenv.hostPlatform.extensions.sharedLibrary}";
      tiff_lib = "${lib.getLib libtiff}/lib/libtiff${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  postPatch = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace glymur/lib/_tiff.py \
        --replace-fail \
          'glymur_config("c")' \
          'ctypes.CDLL("${lib.getLib glibc}/lib/libc.so.6")'
  '';

  nativeCheckInputs = [
    addBinToPathHook
    pytestCheckHook
    scikit-image
  ];

  __propagatedImpureHostDeps = lib.optional stdenv.hostPlatform.isDarwin "/usr/lib/libc.dylib";

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    lxml
    numpy
    pillow
  ];

  disabledTestPaths = [
    # this test involves glymur's different ways of finding the openjpeg path on
    # fsh systems by reading an .rc file and such, and is obviated by the patch
    "tests/test_config.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "glymur" ];

  meta = {
    description = "Tools for accessing JPEG2000 files";
    homepage = "https://github.com/quintusdias/glymur";
    changelog = "https://github.com/quintusdias/glymur/blob/${finalAttrs.src.tag}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
