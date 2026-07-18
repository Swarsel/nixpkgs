{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  glib,
  libsForQt5,
  pkg-config,
  qt6Packages,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sailfish-access-control";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "sailfish-access-control";
    tag = finalAttrs.version;
    hash = "sha256-3gZUz6MZ/dZ1ntPmU89vEoLJ3zPE6Tax/YHw7/MwNCI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  makeFlags = [
    "VERSION=${finalAttrs.version}"
  ];

  # sourceRoot breaks patches
  preConfigure = ''
    cd glib
  '';

  installFlags = [
    "ROOT="
    "PREFIX=${placeholder "out"}"
    "INCDIR=${placeholder "dev"}/include/sailfishaccesscontrol"
  ];

  passthru = {
    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
        versionCheck = true;
      };

      qt5 = libsForQt5.sailfish-access-control-plugin;
      qt6 = qt6Packages.sailfish-access-control-plugin;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "Thin wrapper on top of pwd.h and grp.h of glibc";

    longDescription = ''
      This package provides a thin wrapper library on top of the getuid, getpwuid, getgrouplist, and friends.
      Checking whether a user belongs to a group should be done via this Sailfish Access Control library.

      This will make it easier to fix for instance rerentrancy issues.
    '';

    homepage = "https://github.com/sailfishos/sailfish-access-control";
    changelog = "https://github.com/sailfishos/sailfish-access-control/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;

    pkgConfigModules = [
      "sailfishaccesscontrol"
    ];

    teams = [ lib.teams.lomiri ];
  };
})
