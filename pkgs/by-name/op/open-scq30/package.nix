{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk4,
  just,
  libGL,
  libadwaita,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  nix-update-script,
  pango,
  pkg-config,
  protobuf,
  rustPlatform,
  sqlite,
  wayland,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "open-scq30";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "Oppzippy";
    repo = "OpenSCQ30";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4K/3kulUbUa21YbWh1nYXeeHAIVD/FX8VtWArpij0JQ=";
  };

  postPatch = ''
    patchShebangs ./gui/scripts ./cli/scripts ./scripts
  '';

  nativeBuildInputs = [
    pkg-config
    protobuf
    wrapGAppsHook4
    just
    autoPatchelfHook
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
    sqlite
    libxkbcommon
  ];

  cargoHash = "sha256-1Ccbi/21jTyTPt9WqhnwpBFuD0f90PabwyVRwZI1l0k=";
  env.INSTALL_PREFIX = placeholder "out";

  buildPhase = ''
    just build-cli
    just build-gui
  '';

  # Requires headphones
  doCheck = false;

  installPhase = ''
    just install ${placeholder "out"}
  '';

  # Wayland and X11 libs are required at runtime since winit uses dlopen
  runtimeDependencies = [
    wayland
    libxkbcommon
    libGL
    libx11
    libxcursor
    libxi
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross platform application for controlling settings of Soundcore headphones";
    homepage = "https://github.com/Oppzippy/OpenSCQ30";
    changelog = "https://github.com/Oppzippy/OpenSCQ30/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mkg20001 ];
    mainProgram = "open-scq30";
  };
})
