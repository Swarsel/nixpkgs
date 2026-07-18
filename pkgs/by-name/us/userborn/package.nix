{
  lib,
  fetchFromGitHub,
  libxcrypt,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "userborn";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "nikstur";
    repo = "userborn";
    rev = finalAttrs.version;
    hash = "sha256-mXXakR75Iz6AFf/TYgIHE8SxOri2HyReYUYTT3lCEPA=";
  };

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  buildInputs = [ libxcrypt ];
  cargoHash = "sha256-uAid5GsM9lasVQAYfeo9jwp4xg1MrXdJqtD0l6ME6OQ=";
  sourceRoot = "${finalAttrs.src.name}/rust/userborn";
  stripAllList = [ "bin" ];

  passthru = {
    tests = {
      inherit (nixosTests)
        userborn
        userborn-mutable-users
        userborn-mutable-etc
        userborn-immutable-users
        userborn-immutable-etc
        userborn-static
        ;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Declaratively bear (manage) Linux users and groups";
    homepage = "https://github.com/nikstur/userborn";
    changelog = "https://github.com/nikstur/userborn/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nikstur ];
    platforms = lib.platforms.unix;
    mainProgram = "userborn";
  };
})
