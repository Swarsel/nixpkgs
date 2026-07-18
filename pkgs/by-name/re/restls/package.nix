{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "restls";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "3andne";
    repo = "restls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nlQdBwxHVbpOmb9Wq+ap2i4KI1zJYT3SEqvedDbVH8Q=";
  };

  cargoHash = "sha256-hub64iZNVw/BJjibtDnJ3boIU27DEbYSlMLhFFVJ9ps=";

  meta = {
    description = "Perfect Impersonation of TLS";
    homepage = "https://github.com/3andne/restls";
    changelog = "https://github.com/3andne/restls/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "restls";
  };
})
