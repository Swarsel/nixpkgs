{
  lib,
  stdenv,
  fetchFromGitHub,
  # optional-dependencies
  astropy,
  av,
  buildPythonPackage,
  # tests
  fsspec,
  gitMinimal,
  imageio-ffmpeg,
  isPyPy,
  # native dependencies
  libGL,
  # dependencies
  numpy,
  pillow,
  pillow-heif,
  psutil,
  pytestCheckHook,
  # build-system
  setuptools,
  tifffile,
  writableTmpDirAsHomeHook,
}:

let
  test_images = fetchFromGitHub {
    hash = "sha256-Kh8DowuhcCT5C04bE5yJa2C+efilLxP0AM31XjnHRf4=";
    leaveDotGit = true;
    owner = "imageio";
    repo = "test_images";
    rev = "f676c96b1af7e04bb1eed1e4551e058eb2f14acd";
  };
  libgl = "${libGL.out}/lib/libGL${stdenv.hostPlatform.extensions.sharedLibrary}";
in

buildPythonPackage rec {
  pname = "imageio";
  version = "2.37.2";

  src = fetchFromGitHub {
    owner = "imageio";
    repo = "imageio";
    tag = "v${version}";
    hash = "sha256-8wKTcmnep67zBMYgd6Gpr3wRCIrzYaqfytL1o7iBNAk=";
  };

  postPatch = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace tests/test_core.py \
      --replace-fail 'ctypes.util.find_library("GL")' '"${libgl}"'
  '';

  nativeCheckInputs = [
    fsspec
    gitMinimal
    psutil
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ fsspec.optional-dependencies.github
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export IMAGEIO_USERDIR=$(mktemp -d)
  '';

  build-system = [ setuptools ];

  dependencies = [
    numpy
    pillow
  ];

  disabledTestMarks = [ "needs_internet" ];
  # These tests require the old and vulnerable freeimage binaries; skip.
  disabledTestPaths = [ "tests/test_freeimage.py" ];

  optional-dependencies = {
    bsdf = [ ];
    dicom = [ ];
    feisem = [ ];

    ffmpeg = [
      imageio-ffmpeg
      psutil
    ];

    fits = lib.optionals (!isPyPy) [ astropy ];
    freeimage = [ ];
    heif = [ pillow-heif ];
    lytro = [ ];
    numpy = [ ];
    pillow = [ ];
    pyav = [ av ];
    simpleitk = [ ];
    spe = [ ];
    swf = [ ];
    tifffile = [ tifffile ];
  };

  pyproject = true;
  pytestFlags = [ "--test-images=file://${test_images}" ];

  meta = {
    description = "Library for reading and writing a wide range of image, video, scientific, and volumetric data formats";
    homepage = "https://imageio.readthedocs.io";
    changelog = "https://github.com/imageio/imageio/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
