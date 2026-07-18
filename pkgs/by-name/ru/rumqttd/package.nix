{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rumqttd";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    tag = "rumqttd-${finalAttrs.version}";
    hash = "sha256-WFhVSFAp5ZIqranLpU86L7keQaReEUXxxGhvikF+TBw=";
  };

  cargoHash = "sha256-rVJBYOleIHFNwWNrz0JU8rwiMv9E1QfPjDvtrfXvWlQ=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildAndTestSubdir = "rumqttd";
  # Bump vendored `metrics` past 0.24.2 which fixes a borrow-checker error
  # under newer rustc (https://github.com/rust-lang/rust/issues/141402).
  cargoPatches = [ ./bump-metrics.patch ];
  versionCheckProgramArg = [ "--version" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^rumqttd\\-(.+)$" ];
  };

  meta = {
    description = "High performance MQTT broker";
    homepage = "https://rumqtt.bytebeam.io/";
    changelog = "https://github.com/bytebeamio/rumqtt/releases/tag/rumqttd-${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      griffi-gh
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "rumqttd";
  };
})
