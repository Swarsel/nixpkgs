{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  gtk-layer-shell,
  gtk3,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  # gtk-layer-shell fails to cross-compile due to a hard dependency
  # on gobject-introspection.
  # Disable it when cross-compiling since it's an optional dependency.
  # This disables transparency support.
  withGtkLayerShell ? (stdenv.buildPlatform == stdenv.hostPlatform),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wlogout";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "ArtsyMacaw";
    repo = "wlogout";
    rev = finalAttrs.version;
    hash = "sha256-/tYZy56ku68ziSOhy6Dex9RGy+blkU6CN2ze76y7718=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace style.css \
      --replace "/usr/share/wlogout" "$out/share/wlogout"

    substituteInPlace main.c \
      --replace "/etc/wlogout" "$out/etc/wlogout"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    gtk3
    libxkbcommon
    wayland
    wayland-protocols
  ]
  ++ lib.optionals withGtkLayerShell [
    gtk-layer-shell
  ];

  mesonFlags = [
    "--datadir=${placeholder "out"}/share"
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    inherit (wayland.meta) platforms;
    description = "Wayland based logout menu";
    homepage = "https://github.com/ArtsyMacaw/wlogout";
    changelog = "https://github.com/ArtsyMacaw/wlogout/releases/tag/${finalAttrs.src.rev}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ iogamaster ];
    mainProgram = "wlogout";
  };
})
