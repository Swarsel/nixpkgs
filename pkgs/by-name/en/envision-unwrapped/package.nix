{
  lib,
  stdenv,
  fetchFromGitLab,
  applyPatches,
  appstream-glib,
  cairo,
  cargo,
  desktop-file-utils,
  gdb,
  gdk-pixbuf,
  git,
  glib,
  gtk4,
  gtksourceview5,
  libadwaita,
  libgit2,
  libusb1,
  meson,
  ninja,
  nix-update-script,
  openssl,
  openxr-loader,
  pango,
  pkg-config,
  rustPlatform,
  rustc,
  versionCheckHook,
  vte-gtk4,
  wrapGAppsHook4,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "envision-unwrapped";
  version = "2.0.1";

  src = fetchFromGitLab {
    owner = "gabmus";
    repo = "envision";
    rev = finalAttrs.version;
    hash = "sha256-J1zctfFOyu+uLpctTiAe5OWBM7nXanzQocTGs1ToUMA=";
  };

  patches = [
    ./support-headless-cli.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    cargo
    git
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    gtksourceview5
    libadwaita
    libgit2
    libusb1
    openssl
    openxr-loader
    pango
    vte-gtk4
    zlib
  ];

  postInstall = ''
    wrapProgram $out/bin/envision \
      --prefix PATH : "${lib.makeBinPath [ gdb ]}"
  '';

  # FIXME: error when running `env -i envision`:
  # "HOME env var not defined: NotPresent"
  doInstallCheck = false;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version;

    # TODO: Use srcOnly instead
    src = applyPatches {
      inherit (finalAttrs) src patches;
    };

    hash = "sha256-O3+urY2FlnHfxoJLn4iehnVWf1Y0uATEteyQVnZLxTQ=";
  };

  versionCheckProgram = "${placeholder "out"}/bin/envision";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "UI for building, configuring and running Monado, the open source OpenXR runtime";
    homepage = "https://gitlab.com/gabmus/envision";
    license = lib.licenses.agpl3Only;

    # More maintainers needed!
    # envision (wrapped) requires frequent updates to the dependency list;
    # the more people that can help with this, the better.
    maintainers = with lib.maintainers; [
      coolGi
      Scrumplex
      txkyel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "envision";
    broken = true;
  };
})
