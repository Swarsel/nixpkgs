{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # buildInputs
  jxrlib,
  lcms2,
  lerc,
  libdeflate,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  numpy,
  openjpeg,
  # nativeBuildInputs
  pkgs,
  # tests
  pytestCheckHook,
  setuptools,
  xz,
  zlib,
}:

let
  version = "2026.6.26";
in
buildPythonPackage rec {
  inherit version;
  pname = "imagecodecs";

  src = fetchFromGitHub {
    owner = "cgohlke";
    repo = "imagecodecs";
    tag = "v${version}";
    hash = "sha256-0o4zSf1iCzxph9tQ+b2nShaRWeCBuszf/r85Zg1BGTY=";
  };

  nativeBuildInputs = [
    pkgs.lz4.dev # lz4 was hidden by python3Packages.lz4
    lcms2.dev
    openjpeg.dev
  ];

  buildInputs = [
    jxrlib
    lcms2
    lerc
    libdeflate
    libjpeg
    libpng
    libtiff
    libwebp
    pkgs.lz4
    openjpeg
    xz # liblzma
    zlib
    pkgs.zstd
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    numpy
  ];

  prePatch = ''
    substituteInPlace setup.py \
      --replace-fail "/usr/include/openjpeg" "${openjpeg.dev}/include/openjpeg" \
      --replace-fail "/usr/include/jxrlib" "${jxrlib}/include/jxrlib"
  '';

  pyproject = true;

  pythonImportsCheck = [
    "imagecodecs"
  ];

  meta = {
    description = "Image transformation, compression, and decompression codecs";
    homepage = "https://github.com/cgohlke/imagecodecs";
    changelog = "https://github.com/cgohlke/imagecodecs/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
}
