{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "darklua";
  version = "0.17.3";

  src = fetchFromGitHub {
    owner = "seaofvoices";
    repo = "darklua";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IpTTNt/AlaDRckWq1Ck0A822rAtzeOt9RcB2F7CI5ig=";
  };

  # error: linker `aarch64-linux-gnu-gcc` not found
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-0TtABG+MSz3wdxhLgTZCFVgN8KwcDkVTwn+sZV+abbE=";

  meta = {
    description = "Command line tool that transforms Lua code";
    homepage = "https://darklua.com";
    changelog = "https://github.com/seaofvoices/darklua/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomodachi94 ];
    mainProgram = "darklua";
  };
})
