{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fuse,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "nak";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "fiatjaf";
    repo = "nak";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jewvap5dYDpW7kqN2BvJuaqXG8C+gya9y6NxwPQhR4I=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fuse
  ];

  vendorHash = "sha256-gDBDN+loVtsTTj8J1sFlWqMgcdlKepj/16hLkiQEmTs=";
  # Integration tests fail (requires connection to relays)
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for Nostr things";
    homepage = "https://github.com/fiatjaf/nak";
    changelog = "https://github.com/fiatjaf/nak/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "nak";
  };
})
