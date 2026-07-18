{
  lib,
  stdenv,
  fetchFromGitHub,
  fcft,
  pixman,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sandbar";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "kolunmi";
    repo = "sandbar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uG+/e75s/OQtEotR+8aXTEjW6p3oJM8btuRNgUVmIiQ=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    wayland-scanner
    wayland-protocols
    wayland
    pixman
    fcft
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "DWM-like bar for the river wayland compositor";
    homepage = "https://github.com/kolunmi/sandbar";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fccapria ];
    platforms = lib.platforms.all;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "sandbar";
  };
})
