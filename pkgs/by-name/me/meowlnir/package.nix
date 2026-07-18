{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  olm,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "meowlnir";
  version = "26.06";

  src = fetchFromGitHub {
    inherit tag;
    owner = "maunium";
    repo = "meowlnir";
    hash = "sha256-mhm/CznhaQCgx0ZQ/GArmWrhDS0sPkIkJrP3cAOIFME=";
  };

  buildInputs = [ olm ];
  vendorHash = "sha256-0PgI0m2EsfiZjpOQ9lTfVavHNzKWKFdlmkIz2gqUXM0=";
  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  tag = "v0.2606.0";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Opinionated Matrix moderation bot";
    homepage = "https://github.com/maunium/meowlnir";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ sumnerevans ];
    mainProgram = "meowlnir";
  };
}
