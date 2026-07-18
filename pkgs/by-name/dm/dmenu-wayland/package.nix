{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  fetchpatch,
  glib,
  libxkbcommon,
  makeWrapper,
  meson,
  ninja,
  pango,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "dmenu-wayland";
  version = "0-unstable-2023-05-18";

  src = fetchFromGitHub {
    owner = "nyyManni";
    repo = "dmenu-wayland";
    rev = "a380201dff5bfac2dace553d7eaedb6cea6855f9";
    hash = "sha256-dqFvU2mRYEw7n8Fmbudwi5XMLQ7mQXFkug9D9j4FIrU=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # can be removed when https://github.com/nyyManni/dmenu-wayland/pull/23 is included
    (fetchpatch {
      name = "support-cross-compilation.patch";
      sha256 = "sha256-im16kU8RWrCY0btYOYjDp8XtfGEivemIPlhwPX0C77o=";
      url = "https://github.com/nyyManni/dmenu-wayland/commit/3434410de5dcb007539495395f7dc5421923dd3a.patch";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
    wayland-scanner
  ];

  buildInputs = [
    cairo
    pango
    wayland-protocols
    glib
    wayland
    libxkbcommon
  ];

  postInstall = ''
    wrapProgram $out/bin/dmenu-wl_run \
      --prefix PATH : $out/bin
  '';

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Efficient dynamic menu for wayland (wlroots)";
    homepage = "https://github.com/nyyManni/dmenu-wayland";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "dmenu-wl";
  };
}
