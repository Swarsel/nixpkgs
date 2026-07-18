{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nix-your-shell,
  runCommand,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-your-shell";
  version = "1.4.10";

  src = fetchFromGitHub {
    owner = "MercuryTechnologies";
    repo = "nix-your-shell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u94lxsvJrvpKitDDVCoolqHyZMfnQTGtyBwlCegv7Ro=";
  };

  cargoHash = "sha256-SyWD5TJbCxrFtAV2W4XcO1Rnfp3Ygab66UDBFDuSzJk=";

  passthru = {
    generate-config =
      shell:
      runCommand "nix-your-shell-config" { } ''
        ${lib.getExe nix-your-shell} ${lib.escapeShellArg shell} >> "$out"
      '';

    updateScript = nix-update-script { };
  };

  meta = {
    description = "`nix` and `nix-shell` wrapper for shells other than `bash`";
    homepage = "https://github.com/MercuryTechnologies/nix-your-shell";
    changelog = "https://github.com/MercuryTechnologies/nix-your-shell/releases/tag/v${finalAttrs.version}";
    license = [ lib.licenses.mit ];
    maintainers = with lib.maintainers; [ _9999years ];
    mainProgram = "nix-your-shell";
  };
})
