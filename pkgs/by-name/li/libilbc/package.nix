{
  lib,
  stdenv,
  fetchFromGitHub,
  abseil-cpp_202103,
  cmake,
  gitUpdater,
  ninja,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libilbc";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "TimothyGu";
    repo = "libilbc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GpvHDyvmWPxSt0K5PJQrTso61vGGWHkov7U9/LPrDBU=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
    "doc"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [ abseil-cpp_202103 ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Packaged version of iLBC codec from the WebRTC project";
    homepage = "https://github.com/TimothyGu/libilbc";
    changelog = "https://github.com/TimothyGu/libilbc/blob/v${finalAttrs.version}/NEWS.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.all;
    pkgConfigModules = [ "lilbc" ];
  };
})
