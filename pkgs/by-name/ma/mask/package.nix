{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  lua,
  nix-update-script,
  nodejs,
  php,
  python3,
  ruby,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mask";
  version = "0.11.7";

  src = fetchFromGitHub {
    owner = "jacobdeichert";
    repo = "mask";
    tag = "mask/${finalAttrs.version}";
    hash = "sha256-jz2x3Do+fqDHS7vNdnZsNOj36dRFt/khFaF/ztyKji8=";
  };

  cargoHash = "sha256-HnRNg1/ZVWr6JRIsBf2kH9Xys7Hth4fMI12dClsPKv0=";

  nativeCheckInputs = [
    lua
    nodejs
    php
    python3
    ruby
  ];

  checkFlags = [
    # requires swift which currently fails to build
    "--skip=swift"
  ];

  preCheck = ''
    export PATH=$PATH:$PWD/target/${stdenv.hostPlatform.rust.rustcTarget}/$cargoBuildType
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=^mask/(.*)$" ]; };

  meta = {
    description = "CLI task runner defined by a simple markdown file";
    homepage = "https://github.com/jacobdeichert/mask";
    changelog = "https://github.com/jacobdeichert/mask/blob/mask/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "mask";
  };
})
