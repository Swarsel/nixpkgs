{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fcitx5,
  gettext,
  kdePackages,
  lua5_3,
  pkg-config,
}:

let
  lua = lua5_3;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-lua";
  version = "5.0.17";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = "fcitx5-lua";
    tag = finalAttrs.version;
    hash = "sha256-uEWa1wprWT8vDSHKXHUHEmXBtNHgj94hFuKvBm5GXqc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    gettext
  ];

  buildInputs = [
    fcitx5
    lua
  ];

  __structuredAttrs = true;

  passthru = {
    extraLdLibraries = [ lua ];
  };

  meta = {
    description = "Lua support for Fcitx 5";
    homepage = "https://github.com/fcitx/fcitx5-lua";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
  };
})
