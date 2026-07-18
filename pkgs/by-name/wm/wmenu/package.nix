{
  lib,
  stdenv,
  cairo,
  fetchFromCodeberg,
  libxkbcommon,
  meson,
  ninja,
  pango,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wmenu";
  version = "0.2.0";

  src = fetchFromCodeberg {
    owner = "adnano";
    repo = "wmenu";
    tag = finalAttrs.version;
    hash = "sha256-JkKA3MUfRLsZWgvDyiYdqb8u4nGSfboL6Ecy7poPW1k=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wayland-scanner
  ];

  buildInputs = [
    cairo
    pango
    wayland
    libxkbcommon
    wayland-protocols
    scdoc
  ];

  meta = {
    description = "Efficient dynamic menu for Sway and wlroots based Wayland compositors";
    homepage = "https://codeberg.org/adnano/wmenu";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      eken
      sweiglbosker
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wmenu";
  };
})
