{
  lib,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "md-tui";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "henriklovhaug";
    repo = "md-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1E3R1pR5f65rMMEa3Wh2I1W7JV+WgJuVN23XNpaxWTc=";
  };

  nativeBuildInputs = [ pkg-config ];
  cargoHash = "sha256-IjT5YnU9hJd9trsMEM/lDtZIWd0XFHFesq0XF+j9zPg=";
  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Markdown renderer in the terminal";
    homepage = "https://github.com/henriklovhaug/md-tui";
    changelog = "https://github.com/henriklovhaug/md-tui/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      GaetanLepage
      anas
    ];

    platforms = lib.platforms.all;
    mainProgram = "mdt";
  };
})
