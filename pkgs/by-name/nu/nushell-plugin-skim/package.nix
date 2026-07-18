{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu_plugin_skim";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "idanarye";
    repo = "nu_plugin_skim";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zypldu525L2JieDYoZN/lYlc3ooupAsrTtheGxmyxew=";
  };

  nativeBuildInputs = lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  cargoHash = "sha256-7S4wkRCFEWKbq801boMo6bJ8LFU9gPMUKhFJWhA7AMU=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nushell plugin that adds integrates the skim fuzzy finder";
    homepage = "https://github.com/idanarye/nu_plugin_skim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aftix ];
    mainProgram = "nu_plugin_skim";
  };
})
