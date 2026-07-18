{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixpkgs-vet";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-vet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+A4KmOIOC7glVOdW+jxSwQnrBHVej4QqwxTsOQin07U=";
  };

  cargoHash = "sha256-bWmI79H6yQjxoWxcZ7GgqbxIc8fCLB1I4g9WF2IejVI=";
  doCheck = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to vet (check) Nixpkgs, including its pkgs/by-name directory";
    homepage = "https://github.com/NixOS/nixpkgs-vet";
    changelog = "https://github.com/NixOS/nixpkgs-vet/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mdaniels5757
      philiptaron
      willbush
    ];

    mainProgram = "nixpkgs-vet";
    teams = [ lib.teams.ci ];
  };
})
