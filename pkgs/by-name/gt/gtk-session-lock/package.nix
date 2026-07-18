{
  lib,
  stdenv,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  pkg-config,
  vala,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk-session-lock";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Cu3PO42";
    repo = "gtk-session-lock";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SHKAYmdev08oRB/V6UpfSFqYwplF59IaNSOoWcACPig=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    wayland-scanner
  ];

  buildInputs = [
    gtk3
    wayland
  ];

  # Tests are not fully prepared, but may be enabled in later versions
  doCheck = false;

  meta = {
    description = "Library to use GTK 3 to build screen lockers using ext-session-lock-v1 protocol";
    homepage = "https://github.com/Cu3PO42/gtk-session-lock";
    # The author stated "GTK Session Lock is licensed under the GNU General
    # Public License version 3.0 or any later version approved by me (Cu3PO42)."
    # Since we don't know if the author will approve later versions, we mark gpl3Only
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
  };
})
