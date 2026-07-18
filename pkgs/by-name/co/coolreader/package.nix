{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fribidi,
  libunibreak,
  pkg-config,
  qt5,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coolreader";
  version = "3.2.59";

  src = fetchFromGitHub {
    owner = "buggins";
    repo = "coolreader";
    tag = "cr${finalAttrs.version}";
    hash = "sha256-RgVEOaNBaEuPBC75B8PdCkbqMvEzNmnEYmiI1ny/WFQ=";
  };

  patches = [ ./cmake_policy_version_3_5.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qttools
    fribidi
    libunibreak
    zstd
  ];

  meta = {
    description = "Cross platform open source e-book reader";
    homepage = "https://github.com/buggins/coolreader";
    license = lib.licenses.gpl2Plus; # see https://github.com/buggins/coolreader/issues/80
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "cr3";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
