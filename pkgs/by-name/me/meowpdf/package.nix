{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "meowpdf";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "monoamine11231";
    repo = "meowpdf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q3upQj7ppusWzrmESuPJrBO9kLde9lPLKA1b4jXrKQ0=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-qhoTOYR2K49Bhipnar/RxFFHvTTlwx1kS3YArPlYm/I=";

  meta = {
    description = "PDF viewer for the Kitty terminal with GUI-like usage and Vim-like keybindings written in Rust";
    homepage = "https://github.com/monoamine11231/meowpdf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cafkafk ];
    platforms = lib.platforms.linux;
    mainProgram = "meowpdf";
  };
})
