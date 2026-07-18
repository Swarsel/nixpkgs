{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "obsidian-export";
  version = "25.3.0";

  src = fetchFromGitHub {
    owner = "zoni";
    repo = "obsidian-export";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FcySNccDVeftX5BKVwYXdufsCmG8YuFBQrbSqibbVV8=";
  };

  cargoHash = "sha256-2rP1ks+47fI5Os7ltktPVUzvYss+KkjftrE4G0cl8XI=";

  meta = {
    description = "Rust library and CLI to export an Obsidian vault to regular Markdown";
    homepage = "https://github.com/zoni/obsidian-export";
    changelog = "https://github.com/zoni/obsidian-export/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd2Patent;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "obsidian-export";
  };
})
