{
  lib,
  stdenv,
  fetchFromGitHub,
  bign-handheld-thumbnailer,
  cargo,
  glib,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bign-handheld-thumbnailer";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "MateusRodCosta";
    repo = "bign-handheld-thumbnailer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+iWf5ybCUHlZz3Ybw3bwLKzlsmiVwep2alVDvL9bG2A=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
  ];

  buildInputs = [ glib ];

  mesonFlags = [
    "-Dupdate_mime_database=false"
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-vfTbfg1CAbc//UZtI5trw6znqnNGy6AiCSQNE68vch8=";
  };

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = bign-handheld-thumbnailer;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    # This is based on GIO
    inherit (glib.meta) platforms;
    description = "Thumbnailer for Nintendo handheld systems (Nintendo DS and 3DS) roms and files";
    homepage = "https://github.com/MateusRodCosta/bign-handheld-thumbnailer";
    changelog = "https://github.com/MateusRodCosta/bign-handheld-thumbnailer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "bign-handheld-thumbnailer";
  };
})
