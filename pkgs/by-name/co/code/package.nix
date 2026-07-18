{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenvNoCC,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "code";
  version = "0.6.100";

  src = fetchFromGitHub {
    owner = "just-every";
    repo = "code";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I/QdFRo6FeNtwlwwZXkCkeknJlkTo9wWrhJTZ5fdv7A=";
  };

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-ig90sWozfLZQJ/F6BuhRbLbR4GiyygqAaumO6WOItpw=";
  env.CODE_VERSION = finalAttrs.version;
  # Takes too much time
  doCheck = false;

  postInstall = ''
    ln -s $out/bin/code $out/bin/coder
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "--bin"
    "code"
    "--bin"
    "code-tui"
    "--bin"
    "code-exec"
  ];

  sourceRoot = "${finalAttrs.src.name}/code-rs";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, effective, mind-blowing, coding CLI";
    homepage = "https://github.com/just-every/code";
    changelog = "https://github.com/just-every/code/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "coder";
    downloadPage = "https://github.com/just-every/code/releases";
    priority = 10;
  };
})
