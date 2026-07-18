{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jolt-tui";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jordond";
    repo = "jolt";
    tag = finalAttrs.version;
    hash = "sha256-A8X06Y7Ujl2rN4+op6ixbWaL4Tx9Toj6+jSgRhRcDRM=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  cargoHash = "sha256-5SKyKTQXqcRsmvyHfq4i7RcGiL+3lENcEXU1FgTGsek=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  cargoBuildFlags = [ "--package=jolt-tui" ];

  meta = {
    description = "Terminal-based battery and energy monitor";
    homepage = "https://getjolt.sh";
    changelog = "https://github.com/jordond/jolt/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ EpicEric ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "jolt";
  };
})
