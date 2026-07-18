{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  glib,
  harfbuzz,
  libxkbcommon,
  pango,
  pkg-config,
  scdoc,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wvkbd";
  version = "0.19.4";

  src = fetchFromGitHub {
    owner = "jjsullivan5196";
    repo = "wvkbd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aQA5xY3jDSLsANxNX3mGu+LElyOn6lPjxEaqS1v2JaI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    cairo
    glib
    harfbuzz
    libxkbcommon
    pango
    wayland
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "On-screen keyboard for wlroots";
    homepage = "https://github.com/jjsullivan5196/wvkbd";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
    mainProgram = "wvkbd-mobintl";
  };
})
