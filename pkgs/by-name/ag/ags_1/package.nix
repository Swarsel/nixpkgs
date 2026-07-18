{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  gjs,
  glib-networking,
  gnome-bluetooth,
  gobject-introspection,
  gtk-layer-shell,
  libpulseaudio,
  libsoup_3,
  linux-pam,
  meson,
  networkmanager,
  ninja,
  nix-update-script,
  pkg-config,
  typescript,
  upower,
  wrapGAppsHook3,
}:

buildNpmPackage (finalAttrs: {
  pname = "ags";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "ags";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ebnkUaee/pnfmw1KmOZj+MP1g5wA+8BT/TPKmn4Dkwc=";
    fetchSubmodules = true;
  };

  patches = [
    # Workaround for TypeScript 5.9: https://github.com/Aylur/ags/issues/725#issuecomment-3070009695
    ./ts59.patch
  ];

  postPatch = ''
    chmod u+x ./post_install.sh && patchShebangs ./post_install.sh
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gjs
    gobject-introspection
    typescript
    wrapGAppsHook3
  ];

  # Most of the build inputs here are basically needed for their typelibs.
  buildInputs = [
    gjs
    glib-networking
    gnome-bluetooth
    gtk-layer-shell
    libpulseaudio
    libsoup_3
    linux-pam
    networkmanager
    upower
  ];

  npmDepsHash = "sha256-ucWdADdMqAdLXQYKGOXHNRNM9bhjKX4vkMcQ8q/GZ20=";
  mesonFlags = [ (lib.mesonBool "build_types" true) ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "EWW-inspired widget system as a GJS library";
    homepage = "https://github.com/Aylur/ags";
    changelog = "https://github.com/Aylur/ags/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      johnrtitor
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ags";
  };
})
