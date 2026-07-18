{
  lib,
  stdenv,
  fetchFromGitLab,
  cairo,
  dbus,
  evdev-proto,
  gtk3,
  meson,
  ninja,
  pango,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdecor";
  version = "0.2.5";

  src = fetchFromGitLab {
    owner = "libdecor";
    repo = "libdecor";
    rev = finalAttrs.version;
    hash = "sha256-sUktv/k+4IdJ55uH3F6z8XqaAOTic6miuyZ9U+NhtQQ=";
    domain = "gitlab.freedesktop.org";
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
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    cairo
    dbus
    pango
    gtk3
  ]
  ++ lib.optional stdenv.hostPlatform.isFreeBSD evdev-proto;

  mesonFlags = [
    (lib.mesonBool "demo" false)
  ];

  meta = {
    description = "Client-side decorations library for Wayland clients";
    homepage = "https://gitlab.freedesktop.org/libdecor/libdecor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
  };
})
