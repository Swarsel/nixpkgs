{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  eigen,
  fftw,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libsakura";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "tnakazato";
    repo = "sakura";
    tag = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-QkVZXb9m4iMTeFYUOK1u+9HM0oMu48bwe7AovafanVU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    eigen
    fftw
  ];

  cmakeFlags = [
    (lib.cmakeFeature "SIMD_ARCH" "GENERIC")
    (lib.cmakeBool "PYTHON_BINDING" false)
    (lib.cmakeBool "BUILD_DOC" false)
    (lib.cmakeBool "ENABLE_TEST" false)
  ];

  __structuredAttrs = true;
  sourceRoot = "${finalAttrs.src.name}/${finalAttrs.pname}";

  meta = {
    description = "Thread-safe library for signal processing in radio astronomy";
    homepage = "https://tnakazato.github.io/sakura/";
    changelog = "https://github.com/tnakazato/sakura/releases/tag/${finalAttrs.pname}-${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ kiranshila ];
    platforms = lib.platforms.unix;
  };
})
