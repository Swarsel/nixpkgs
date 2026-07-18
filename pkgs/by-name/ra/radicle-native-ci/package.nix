{
  lib,
  fetchFromRadicle,
  gitMinimal,
  radicle-node,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "radicle-native-ci";
  version = "0.14.0";

  src = fetchFromRadicle {
    repo = "z3qg5TKmN83afz2fj9z3fQjU8vaYE";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u0KuQ+ii1lRl2f0SduZZtapuDHeSvl9T00esHeCuIq4=";
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV";
    seed = "seed.radicle.dev";
  };

  cargoHash = "sha256-6Hkyf9siagH/GPVxOePpkV2BMloXEamrJSJCnEfIeSo=";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    radicle-node
    gitMinimal
  ];

  preCheck = ''
    git config --global user.name nixbld
    git config --global user.email nixbld@example.com
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Radicle CI adapter for native CI";
    homepage = "https://radicle.network/nodes/seed.radicle.dev/rad:z3qg5TKmN83afz2fj9z3fQjU8vaYE";
    changelog = "https://radicle.network/nodes/seed.radicle.dev/rad:z3qg5TKmN83afz2fj9z3fQjU8vaYE/tree/NEWS.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    mainProgram = "radicle-native-ci";
    teams = [ lib.teams.radicle ];
  };
})
