{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  onetbb,
  openvino,
  pcre2,
  pkg-config,
  sentencepiece,
}:

let
  inherit (lib) cmakeBool cmakeFeature;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "openvino-tokenizers";
  version = "2026.2.1.0";

  src =
    assert lib.hasPrefix openvino.version finalAttrs.version;
    fetchFromGitHub {
      owner = "openvinotoolkit";
      repo = "openvino_tokenizers";
      tag = finalAttrs.version;
      hash = "sha256-K0Zdo9er+s9/PWvBmVJTsWOSgzzZ5De7sRLMNEpxf/U=";
    };

  patches = [
    # Use system pcre2 via pkg-config rather than FetchContent, and add
    # sentencepiece's binary dir to the include path so cmake-generated config.h
    # is found at compile time.
    ./use-system-pcre2-and-sentencepiece-binary-dir.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    onetbb
    openvino
    pcre2
  ];

  cmakeFlags = [
    (cmakeFeature "OpenVINO_DIR" "${openvino}/runtime/cmake")
    # Supply FetchContent source so nothing is downloaded at build time.
    (cmakeFeature "FETCHCONTENT_SOURCE_DIR_SENTENCEPIECE" "${sentencepiece.src}")
    # Install library to standard lib/ rather than runtime/lib/<arch>/
    (cmakeFeature "OPENVINO_TOKENIZERS_INSTALL_LIBDIR" "lib")
    (cmakeFeature "OPENVINO_TOKENIZERS_INSTALL_BINDIR" "bin")
    (cmakeBool "BUILD_CPP_EXTENSION" true)
    (cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
  ];

  __structuredAttrs = true;
  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenVINO Tokenizers - text tokenisation extensions for OpenVINO";
    homepage = "https://github.com/openvinotoolkit/openvino_tokenizers";
    changelog = "https://github.com/openvinotoolkit/openvino_tokenizers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpds ];
    platforms = lib.platforms.linux;
  };
})
