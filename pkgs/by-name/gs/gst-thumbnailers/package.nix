{
  lib,
  stdenv,
  fetchFromGitLab,
  callPackage,
  cargo,
  fontconfig,
  glycin-loaders,
  gst_all_1,
  libglycin,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  shared-mime-info,
  wrapGAppsNoGuiHook,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-thumbnailers";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gst-thumbnailers";
    tag = finalAttrs.version;
    hash = "sha256-QxOdjtPnX4ulGsenASQzKJckbIqfSU7FeR+iW1ZL878=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    fontconfig
    libglycin
    glycin-loaders
  ];

  doCheck = true;

  nativeCheckInputs = [
    # fontconfig tries to write to `~/.cache/fontconfig`
    writableTmpDirAsHomeHook
  ];

  # Fix missing glycin loaders (glycin-loaders) and incorrectly detected
  # MIME types (shared-mime-info).
  preCheck = ''
    export XDG_DATA_DIRS=${glycin-loaders}/share:${shared-mime-info}/share:$XDG_DATA_DIRS
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-irXwoGGcVeZza02Ob5HTkeTBD3PaXmfJ4vuqXk9BadA=";
  };

  mesonCheckFlags = [ "-v" ];

  passthru = {
    tests.thumbnailers = callPackage ./tests.nix { };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Generate thumbnailer for video and audio files";
    homepage = "https://gitlab.gnome.org/GNOME/gst-thumbnailers";
    changelog = "https://gitlab.gnome.org/GNOME/gst-thumbnailers/-/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
      thunze
    ];

    platforms = lib.platforms.linux;
  };
})
