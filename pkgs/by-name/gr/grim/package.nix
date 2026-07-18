{
  lib,
  stdenv,
  fetchFromGitLab,
  libjpeg,
  libpng,
  meson,
  ninja,
  pixman,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grim";
  version = "1.5.0";

  src = fetchFromGitLab {
    owner = "emersion";
    repo = "grim";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oPo6zrS3gCnviIK0+gPvtal+6c7fNFWtXnAA0YfaS+U=";
    domain = "gitlab.freedesktop.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    pixman
    libpng
    libjpeg
    wayland
    wayland-protocols
  ];

  mesonFlags = [ (lib.mesonBool "werror" false) ];

  depsBuildBuild = [
    # To find wayland-scanner
    pkg-config
  ];

  meta = {
    description = "Grab images from a Wayland compositor";
    homepage = "https://gitlab.freedesktop.org/emersion/grim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaneliman ];
    platforms = lib.platforms.linux;
    mainProgram = "grim";
  };
})
