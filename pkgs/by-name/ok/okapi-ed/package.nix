{
  lib,
  fetchFromGitHub,
  makeBinaryWrapper,
  nix-update-script,
  ripgrep,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "okapi-ed";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "nk9";
    repo = "okapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1cfnEhJiCtESp+a7vEANocPgxQVr88FJf3EYLjuaIDI=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  cargoHash = "sha256-+vb0ju5FUOWAUTysUYh95d0o8fzdaPlfwszGcTUPQzo=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram "$out/bin/okapi" \
      --prefix PATH : "${lib.makeBinPath [ ripgrep ]}"
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Find lines across files by regex and edit them all at once with your $EDITOR";
    homepage = "https://github.com/nk9/okapi";
    changelog = "https://github.com/nk9/okapi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      toelke
      nadir-ishiguro
    ];

    platforms = lib.platforms.unix;
    mainProgram = "okapi";
  };
})
