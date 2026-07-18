{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  yq,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "koto";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "koto-lang";
    repo = "koto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-47eDSohLH/cMmMwjUENNeT5danpgMKLPEMzEUACrpiY=";
  };

  postPatch = ''
    tomlq -ti 'del(.bench)' crates/koto/Cargo.toml
  '';

  nativeBuildInputs = [
    yq # for `tomlq`
  ];

  cargoHash = "sha256-mQxPwU/f7/AastJmGBZOAxGKaZBWTQUkb2KIuC6MSfE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoBuildFlags = [ "--package=koto_cli" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple, expressive, embeddable programming language";
    homepage = "https://github.com/koto-lang/koto";
    changelog = "https://github.com/koto-lang/koto/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "koto";
  };
})
