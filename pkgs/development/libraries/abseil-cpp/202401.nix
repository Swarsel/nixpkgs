{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gtest,
  cxxStandard ? null,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abseil-cpp";
  version = "20240116.3";

  src = fetchFromGitHub {
    owner = "abseil";
    repo = "abseil-cpp";
    tag = finalAttrs.version;
    hash = "sha256-VfC8kQtGlOew9iVKxQ7kIgqFMvHiDpSBhvyNOfneuwo=";
  };

  patches = [
    # Fixes: clang++: error: unsupported option '-msse4.1' for target 'aarch64-apple-darwin'
    # https://github.com/abseil/abseil-cpp/pull/1707
    (fetchpatch {
      hash = "sha256-r6QnHPnwPwOE/hv4kLNA3FqNq2vU/QGmwAc5q0/q1cs=";
      name = "fix-compile-breakage-on-darwin";
      url = "https://github.com/abseil/abseil-cpp/commit/6dee153242d7becebe026a9bed52f4114441719d.patch";
    })
  ];

  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ gtest ];

  cmakeFlags = [
    "-DABSL_BUILD_TEST_HELPERS=ON"
    "-DABSL_USE_EXTERNAL_GOOGLETEST=ON"
    "-DBUILD_SHARED_LIBS=${if static then "OFF" else "ON"}"
  ]
  ++ lib.optionals (cxxStandard != null) [
    "-DCMAKE_CXX_STANDARD=${cxxStandard}"
  ];

  meta = {
    description = "Open-source collection of C++ code designed to augment the C++ standard library";
    homepage = "https://abseil.io/";
    changelog = "https://github.com/abseil/abseil-cpp/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.GaetanLepage ];
    platforms = lib.platforms.all;
  };
})
