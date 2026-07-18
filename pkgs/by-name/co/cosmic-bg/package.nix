{
  lib,
  stdenv,
  fetchFromGitHub,
  cosmic-wallpapers,
  just,
  libcosmicAppHook,
  nasm,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-bg";
  version = "1.2.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-bg";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-r/7eyaUwxXNbfzO+7TCa25JaOefGF/hY+PBHFJtpoiw=";
  };

  postPatch = ''
    substituteInPlace config/src/lib.rs data/v1/all \
      --replace-fail '/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg' \
      "${cosmic-wallpapers}/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg"
  '';

  nativeBuildInputs = [
    just
    libcosmicAppHook
    nasm
  ];

  cargoHash = "sha256-jU6KesqaHnfVZfCtDKrG/pVaJzh3Q5Q6UDMlOoFiLeY=";
  __structuredAttrs = true;
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  separateDebugInfo = true;

  passthru = {
    tests = {
      inherit (nixosTests)
        cosmic
        cosmic-autologin
        cosmic-noxwayland
        cosmic-autologin-noxwayland
        ;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "epoch-(.*)"
      ];
    };
  };

  meta = {
    description = "Applies Background for the COSMIC Desktop Environment";
    homepage = "https://github.com/pop-os/cosmic-bg";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-bg";
    teams = [ lib.teams.cosmic ];
  };
})
