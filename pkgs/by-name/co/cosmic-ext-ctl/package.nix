{
  lib,
  fetchFromGitHub,
  cosmic-comp,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-ext-ctl";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "cosmic-ctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-URqNhkC1XrXYxr14K6sT3TLso38eWLMA+WplBdj52Vg=";
  };

  cargoHash = "sha256-OL1LqOAyIFFCGIp3ySdvEXJ1ECp9DgC/8mfAPo/E7k4=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/cosmic-ctl";
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (cosmic-comp.meta) platforms;
    description = "CLI for COSMIC Desktop configuration management";
    homepage = "https://github.com/cosmic-utils/cosmic-ctl";
    changelog = "https://github.com/cosmic-utils/cosmic-ctl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    mainProgram = "cosmic-ctl";
  };
})
