{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  libsecret,
  nix-update-script,
  openssl,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tasks";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tasks";
    tag = finalAttrs.version;
    hash = "sha256-u8TYKXFbrF2fseMNGNOBAkgCA53af5gi1PDKS2FIE5I=";
  };

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  buildInputs = [
    libsecret
    openssl
    sqlite
  ];

  cargoHash = "sha256-96uk8tQgvDbgZTC0ypzWRmWNToCUGnVefPyhI69nxxs=";
  __structuredAttrs = true;
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/tasks"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple task management application for the COSMIC desktop";
    homepage = "https://github.com/cosmic-utils/tasks";
    changelog = "https://github.com/cosmic-utils/tasks/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      GaetanLepage
      HeitorAugustoLN
    ];

    platforms = lib.platforms.linux;
    mainProgram = "tasks";
  };
})
