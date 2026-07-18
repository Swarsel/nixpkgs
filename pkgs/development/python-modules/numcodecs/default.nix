{
  lib,
  stdenv,
  buildPythonPackage,
  # optional-dependencies
  crc32c,
  cython,
  fetchPypi,
  google-crc32c,
  importlib-metadata,
  # tests
  msgpack,
  # dependencies
  numpy,
  pcodec,
  py-cpuinfo,
  pytestCheckHook,
  python,
  pyzstd,
  # build-system
  setuptools,
  setuptools-scm,
  typing-extensions,
  zstd,
}:

buildPythonPackage rec {
  pname = "numcodecs";
  version = "0.16.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DQ+2CFL4TAvZVDzE0que79N/yO/MQQrNR3fmKh0wAxg=";
  };

  preBuild = lib.optionalString (stdenv.hostPlatform.isx86 && !stdenv.hostPlatform.avx2Support) ''
    export DISABLE_NUMCODECS_AVX2=1
  '';

  nativeCheckInputs = [
    pytestCheckHook
    importlib-metadata
    pyzstd
    zstd
  ]
  ++ lib.concatAttrValues optional-dependencies;

  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = "pushd $out/${python.sitePackages}";
  postCheck = "popd";

  build-system = [
    setuptools
    setuptools-scm
    cython
    py-cpuinfo
  ];

  dependencies = [
    numpy
    typing-extensions
  ];

  disabledTestPaths = [
    # https://github.com/zarr-developers/numcodecs/issues/815
    "numcodecs/tests/test_pcodec.py"
  ];

  optional-dependencies = {
    crc32c = [ crc32c ];
    google_crc32c = [ google-crc32c ];
    msgpack = [ msgpack ];
    pcodec = [ pcodec ];
    # zfpy = [ zfpy ];
  };

  pyproject = true;

  meta = {
    description = "Buffer compression and transformation codecs for use in data storage and communication applications";
    homepage = "https://github.com/zarr-developers/numcodecs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
