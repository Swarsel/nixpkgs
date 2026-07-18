{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fcitx5,
  fmt,
  gettext,
  kdePackages,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-array";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "ray2501";
    repo = "fcitx5-array";
    tag = finalAttrs.version;
    hash = "sha256-oI164h9MvK3vYwquF8icfyUzyeAhKnEWFSfs/lkwaeE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    gettext
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    fmt
    fcitx5
    sqlite
  ];

  meta = {
    description = "Array wrapper for Fcitx5";
    homepage = "https://github.com/ray2501/fcitx5-array";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ yanganto ];
    platforms = lib.platforms.linux;
  };
})
