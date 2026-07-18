{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ut";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "boost-ext";
    repo = "ut";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VCTrs0CMr4pUrJ2zEsO8s7j16zOkyDNhBc5zw0rAAZI=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBOOST_UT_ALLOW_CPM_USE=OFF"
  ];

  meta = {
    description = "C++20 μ(micro)/Unit Testing Framework";
    homepage = "https://github.com/boost-ext/ut";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.all;
  };
})
