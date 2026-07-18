{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo-tauri,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arnis";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "louis-e";
    repo = "arnis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mdBicZIHonfVs2r6eNRNdpr8saZ54k1m0czWRqBYvq4=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook

    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
  ];

  cargoHash = "sha256-G0lEKjF9xNF4zs/+yf/8fvZTRZOH6IGud0tpEB86IXE=";

  checkFlags = [
    # Fail to run in sandbox environment
    "--skip=map_transformation::translate::translator::tests::test_translate_by_vector"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram =
    let
      binSubdirectory =
        if stdenv.hostPlatform.isLinux then
          "bin"
        else if stdenv.hostPlatform.isDarwin then
          "Applications/Arnis.app/Contents/MacOS"
        else
          throw "Unsuported system";
    in
    "${placeholder "out"}/${binSubdirectory}/arnis";

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (cargo-tauri.hook.meta) platforms;
    description = "Real world location generator for Minecraft Java Edition";

    longDescription = ''
      Open source project written in Rust generates any chosen location from
      the real world in Minecraft Java Edition with a high level of detail.
    '';

    homepage = "https://github.com/louis-e/arnis";
    changelog = "https://github.com/louis-e/arnis/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nartsiss ];
    mainProgram = "arnis";
  };
})
