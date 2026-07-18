{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "regolith";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Bedrock-OSS";
    repo = "regolith";
    tag = finalAttrs.version;
    hash = "sha256-jaUpNPRh3mZPz2z9+1mG5337NHaakP+4HOWENCzIfTY=";
  };

  vendorHash = "sha256-qak4USPwOxPHJ2GriVKhjdGazW4YkM3OaoMlqKPbtag=";
  # Requires network access.
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X main.buildSource=nix"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Add-on Compiler for the Bedrock Edition of Minecraft";
    homepage = "https://github.com/Bedrock-OSS/regolith";
    changelog = "https://github.com/Bedrock-OSS/regolith/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arexon ];
    mainProgram = "regolith";
  };
})
