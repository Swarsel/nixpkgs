{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2_3,
  cmake,
  fetchzip,
  fmt,
  python3,
  simdImplementation ? "none", # see https://github.com/contour-terminal/libunicode/blob/v0.7.0/CMakeLists.txt#L53 for options
}:

let
  ucd-version = "17.0.0";

  ucd-src = fetchzip {
    hash = "sha256-k2OFy8xPvn+Bboyr1EsmZNeVDOglvk2kSZ+H17YaX60=";
    stripRoot = false;
    url = "https://www.unicode.org/Public/${ucd-version}/ucd/UCD.zip";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libunicode";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "contour-terminal";
    repo = "libunicode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EBu8zn5XritudZmBvQmjOmU08XLjhyKI6hVCrnWoR6k=";
  };

  # Fix: set_target_properties Can not find target to add properties to: Catch2, et al.
  patches = [ ./remove-target-properties.diff ];

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    catch2_3
    fmt
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LIBUNICODE_SIMD_IMPLEMENTATION" simdImplementation)
    (lib.cmakeFeature "LIBUNICODE_UCD_DIR" "${ucd-src}")
  ];

  meta = {
    description = "Modern C++20 Unicode library";
    homepage = "https://github.com/contour-terminal/libunicode";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ moni ];
    platforms = lib.platforms.unix;
    mainProgram = "unicode-query";
  };
})
