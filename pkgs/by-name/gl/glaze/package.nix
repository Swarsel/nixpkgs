{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openssl,
  enableInterop ? true,
  enableSIMD ? stdenv.hostPlatform.avx2Support,
  enableSSL ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "glaze";
  version = "7.8.4";

  src = fetchFromGitHub {
    owner = "stephenberry";
    repo = "glaze";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AyDdyj3uN+IZWGItO87NLMIXRU8Irq8gBI3Q3zqKKzU=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = lib.optionals enableSSL [ openssl ];

  # https://github.com/stephenberry/glaze/blob/main/CMakeLists.txt
  cmakeFlags = [
    (lib.cmakeBool "glaze_DISABLE_SIMD_WHEN_SUPPORTED" (!enableSIMD))
    (lib.cmakeBool "glaze_ENABLE_SSL" enableSSL)
    (lib.cmakeBool "glaze_BUILD_INTEROP" enableInterop)
    (lib.cmakeBool "glaze_ENABLE_FUZZING" (!stdenv.hostPlatform.isMusl))
  ];

  meta = {
    description = "Extremely fast, in memory, JSON and interface library for modern C++";
    homepage = "https://stephenberry.github.io/glaze/";
    changelog = "https://github.com/stephenberry/glaze/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      moni
      miniharinn
    ];

    platforms = lib.platforms.all;
  };
})
