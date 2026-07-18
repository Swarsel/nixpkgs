{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  cairo,
  cargo,
  desktop-file-utils,
  gdk-pixbuf,
  glib,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pango,
  pipewire,
  pkg-config,
  rustPlatform,
  rustc,
  wireplumber,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pwvucontrol";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "saivert";
    repo = "pwvucontrol";
    tag = finalAttrs.version;
    hash = "sha256-Y5O/KkYYNDysZ3H0vk0qj2DOkmx/Z4vJELr9oydxpt8=";
  };

  postPatch = ''
    substituteInPlace src/meson.build --replace-fail \
      "'src' / rust_target / meson.project_name()," \
      "'src' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name(),"
  '';

  nativeBuildInputs = [
    blueprint-compiler
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
    pipewire
    wireplumber
  ];

  # For https://github.com/saivert/pwvucontrol/blob/7bf43c746cd49fffbfb244ac4474742c6b3737a9/src/meson.build#L45-L46
  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-pw7UrD4EFd04mxy8Cz3tif+lzlnemIjFkB7VVOnAA1E=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pipewire Volume Control";
    homepage = "https://github.com/saivert/pwvucontrol";
    changelog = "https://github.com/saivert/pwvucontrol/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      Guanran928
      johnrtitor
      ilkecan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pwvucontrol";
  };
})
