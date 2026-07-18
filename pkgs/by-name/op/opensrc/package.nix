{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "opensrc";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "opensrc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qRKbb2CA5omhFrxtKiEHEX4eH2ayvY8VZ/hH5Uckm8A=";
  };

  strictDeps = true;
  cargoHash = "sha256-ewGecSgnMkZTNyJuVWZ/195BTVv2L2QIZ7jRUtnD8jY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  sourceRoot = "${finalAttrs.src.name}/packages/opensrc/cli";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fetch source code for npm packages to give AI coding agents deeper context";
    homepage = "https://github.com/vercel-labs/opensrc";
    changelog = "https://github.com/vercel-labs/opensrc/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ airrnot ];
    platforms = lib.platforms.all;
    mainProgram = "opensrc";
  };
})
