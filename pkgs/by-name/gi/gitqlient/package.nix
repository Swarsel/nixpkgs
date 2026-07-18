{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gitqlient";
  version = "1.6.3-unstable-2025-09-11"; # cmake does not install correctly on tagged release

  src = fetchFromGitHub {
    owner = "francescmaestre";
    repo = "gitqlient";
    rev = "faa3e2c19205123944bb88427a569c6f1b4366a1";
    hash = "sha256-CBgzTwJWssL0NaNqfesHkOG4pi6QQYxjxWHFcG00U0U=";
    fetchSubmodules = true;
  };

  patches = [
    # fetcher removes .git directory, but cmake attempts to update submodules if .git is missing
    ./dont-attempt-submodule-update.patch
    # install logic in unstable is slightly better, but still attempts to install to source tree, not store
    ./install-to-store.patch
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations"; # QCheckBox::stateChanged is deprecated

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Multi-platform Git client written with Qt";
    homepage = "https://github.com/francescmaestre/GitQlient";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "gitqlient";
  };
})
