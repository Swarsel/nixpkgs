{
  lib,
  fetchFromGitHub,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ytsub";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "sarowish";
    repo = "ytsub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CrYRQ+0WJ6VDG+Y4J0Wk22wcNb+0SxhRbzPJRXQNTjs=";
  };

  buildInputs = [ sqlite ];
  cargoHash = "sha256-8p2//37ATU9d3kMq0tM6Pr+wqbrfOh8Z4fxgwhU4rpA=";
  __structuredAttrs = true;

  meta = {
    description = "Subscriptions only TUI Youtube client";
    homepage = "https://github.com/sarowish/ytsub";
    changelog = "https://github.com/sarowish/ytsub/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sarowish ];
    mainProgram = "ytsub";
  };
})
