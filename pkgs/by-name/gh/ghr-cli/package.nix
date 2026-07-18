{
  lib,
  fetchFromGitHub,
  gitMinimal,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ghr-cli";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "chenyukang";
    repo = "ghr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ELYWoGUP6s2Trtnk9zgDLlT7MtaiHzfsFbzH+LmsKDE=";
  };

  cargoHash = "sha256-siMxS08K+7L8f9A32gEWwQF9PAQh5UPMA+xTkTlz13o=";

  nativeCheckInputs = [
    gitMinimal
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast terminal workspace for staying on top of GitHub";
    homepage = "https://catcoding.me/ghr/";
    changelog = "https://github.com/chenyukang/ghr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pborzenkov ];
    mainProgram = "ghr";
  };
})
