{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  bluez,
  cargo,
  dbus,
  desktop-file-utils,
  gtk4,
  libadwaita,
  libpulseaudio,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "overskride";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "kaii-lb";
    repo = "overskride";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JKYf0172sK/+IqtQqmeHOwC/P563ww+stEc3gxNwe/I=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    appstream-glib
    blueprint-compiler
    meson
    ninja
    cargo
    rustc
  ];

  buildInputs = [
    dbus
    gtk4
    libadwaita
    bluez
    libpulseaudio
  ];

  cargoHash = "sha256-q1g+6JFW+euYCq2uMYQn4R0AP4yt5/cJoP88AXg9NLw=";

  buildPhase = ''
    runHook preBuild

    meson setup build --prefix $out && cd build
    meson compile && meson devenv

    runHook postBuild
  '';

  # The "Validate appstream file" test fails.
  doCheck = false;

  preFixup = ''
    glib-compile-schemas $out/share/gsettings-schemas/overskride-${finalAttrs.version}/glib-2.0/schemas
  '';

  meta = {
    description = "Bluetooth and Obex client that is straight to the point, DE/WM agnostic, and beautiful";
    homepage = "https://github.com/kaii-lb/overskride";
    changelog = "https://github.com/kaii-lb/overskride/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      mrcjkb
      ilkecan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "overskride";
  };
})
