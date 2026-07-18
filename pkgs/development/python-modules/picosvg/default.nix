{
  lib,
  stdenv,
  fetchFromGitHub,
  absl-py,
  buildPythonPackage,
  fetchpatch,
  lxml,
  pytestCheckHook,
  setuptools-scm,
  skia-pathops,
}:
buildPythonPackage rec {
  pname = "picosvg";
  version = "0.22.3";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "picosvg";
    tag = "v${version}";
    hash = "sha256-ocdHF0kYnfllpvul32itu1QtlDrqVeq5sT8Ecb5V1yk=";
  };

  patches = [
    # Fix test failures with skia-pathops 0.9.x (m143)
    # https://github.com/googlefonts/picosvg/pull/331
    (fetchpatch {
      hash = "sha256-fR3FfnEPHwSO1rMtmQEr1pyvByTx8T53FxSpuAKWIjw=";
      url = "https://github.com/googlefonts/picosvg/commit/885ee64b75f526e938eb76e09fab7d93e946a355.patch";
    })
  ];

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    absl-py
    lxml
    skia-pathops
  ];

  # a few tests are failing on aarch64
  doCheck = !stdenv.hostPlatform.isAarch64;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Tool to simplify SVGs";
    homepage = "https://github.com/googlefonts/picosvg";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ _999eagle ];
    mainProgram = "picosvg";
  };
}
