{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  just,
  libcosmicAppHook,
  nix-update-script,
  pipewire,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-ext-applet-privacy-indicator";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "D-Brox";
    repo = "cosmic-ext-applet-privacy-indicator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LfvnVkyXRl58YAXi98B/c0DXve+tT4picRlT6+t4Hqw=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [ pipewire ];
  cargoHash = "sha256-Tbcjnbjyo+FoYtRe5KnPiEzV+1PkzHOnbVDRe/pJul0=";

  cargoPatches = [
    (fetchpatch {
      hash = "sha256-BN32JHouyIqJzBR6Mlp2pw/JhU5c6hdtG+P2SEl/0pA=";
      name = "deduplicate-sctk.patch";
      url = "https://patch-diff.githubusercontent.com/raw/D-Brox/cosmic-ext-applet-privacy-indicator/pull/7.diff?full_index=1";
    })
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-privacy-indicator"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Privacy indicator applet for the COSMIC Desktop Environment";
    homepage = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator";
    changelog = "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-privacy-indicator";
  };
})
