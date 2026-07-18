{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  libaom,
  libde265,
  # native dependencies
  libheif,
  nasm,
  numpy,
  # tests
  opencv4,
  # dependencies
  pillow,
  pkg-config,
  pytestCheckHook,
  setuptools,
  x265,
}:

buildPythonPackage rec {
  pname = "pillow-heif";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "bigcat88";
    repo = "pillow_heif";
    tag = "v${version}";
    hash = "sha256-EaislmA4v2qKCDQ87I85Pn8IlS4VJWyNXkITipKSBC8=";
  };

  postPatch = ''
    sed -i '/addopts/d' pyproject.toml
    substituteInPlace setup.py \
      --replace-warn ', "-Werror"' ""
  '';

  nativeBuildInputs = [
    cmake
    nasm
    pkg-config
  ];

  buildInputs = [
    libaom
    libde265
    libheif
    x265
  ];

  env = {
    RELEASE_FULL_FLAG = 1;
  };

  nativeCheckInputs = [
    opencv4
    numpy
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ pillow ];

  disabledTests = [
    # Time sensitive speed test, not reproducible
    "test_decode_threads"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # https://github.com/bigcat88/pillow_heif/issues/89
    # not reproducible in nixpkgs
    "test_opencv_crash"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # RuntimeError: Encoder plugin generated an error: Unsupported bit depth: Bit depth not supported by x265
    "test_open_heif_compare_non_standard_modes_data"
    "test_open_save_disable_16bit"
    "test_save_bgr_16bit_to_10_12_bit"
    "test_save_bgra_16bit_to_10_12_bit"
    "test_premultiplied_alpha"
    "test_hdr_save"
    "test_I_color_modes_to_10_12_bit"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pillow_heif" ];

  meta = {
    description = "Python library for working with HEIF images and plugin for Pillow";
    homepage = "https://github.com/bigcat88/pillow_heif";
    changelog = "https://github.com/bigcat88/pillow_heif/releases/tag/${src.tag}";

    license = with lib.licenses; [
      bsd3
      lgpl3
    ];

    maintainers = with lib.maintainers; [
      dandellion
      kuflierl
    ];
  };
}
