{
  lib,
  stdenv,
  fetchFromGitHub,
  # build
  cmake,
  # runtime
  espeak-ng,
  fetchpatch,
  onnxruntime,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "piper-phonemize";
  version = "2023.11.14-4";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "piper-phonemize";
    tag = finalAttrs.version;
    hash = "sha256-pj1DZUhy3XWGn+wNtxKKDWET9gsfofEB0NZ+EEQz9q0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    espeak-ng
    onnxruntime
  ];

  cmakeFlags = [
    "-DONNXRUNTIME_DIR=${onnxruntime.dev}"
    "-DESPEAK_NG_DIR=${espeak-ng}"
  ];

  meta = {
    description = "C++ library for converting text to phonemes for Piper";
    homepage = "https://github.com/rhasspy/piper-phonemize";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
