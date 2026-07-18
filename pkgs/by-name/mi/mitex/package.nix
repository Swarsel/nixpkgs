{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  typst,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mitex";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "mitex-rs";
    repo = "mitex";
    tag = finalAttrs.version;
    hash = "sha256-LoGgRiIQQEKvyYIVjvEjg7OuzDl5hmPsrnunDMPfPLI=";
  };

  nativeBuildInputs = [ typst ];
  cargoHash = "sha256-Y/RCUAPohQ7lKPUM07zXM/2/RQpqUmF7cr19GUVVk4Y=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildAndTestSubdir = "crates/mitex-cli";
  cargoBuildFlags = [ "--features generate-spec" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "LaTeX support for Typst, CLI for MiTeX";
    homepage = "https://mitex-rs.github.io/mitex/";
    changelog = "https://github.com/mitex-rs/mitex/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chillcicada ];
    mainProgram = "mitex";
    downloadPage = "https://github.com/mitex-rs/mitex";
  };
})
