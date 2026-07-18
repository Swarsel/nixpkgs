{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wtcat";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "pervrosen";
    repo = "wtcat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jmI5XA8DfsLOKbxsfCE3jSYXP9e2m5Ax4pUYCBDprKw=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-DNy1Hz0g0HKDdnXjiLSmDGKaI6sONaxkNXy/zoXErlk=";
  __structuredAttrs = true;

  cargoPatches = [
    # https://github.com/pervrosen/wtcat/pull/1
    (fetchpatch2 {
      hash = "sha256-5XFKgL7+xSs3entwEJMpaa3EgQefPAmkHs5zGDBFasM=";
      url = "https://github.com/pervrosen/wtcat/commit/b7e2d319147842dfe7246a512a7a2a6aade6d192.patch";
    })
  ];

  meta = {
    description = "WebTransport CLI";
    homepage = "https://github.com/pervrosen/wtcat";
    changelog = "https://github.com/pervrosen/wtcat/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "wtcat";
  };
})
