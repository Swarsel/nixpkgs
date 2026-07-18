{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  cargo-tauri,
  cinny,
  desktop-file-utils,
  glib-networking,
  jq,
  makeBinaryWrapper,
  moreutils,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cinny-desktop";
  version = "4.12.5";

  src = fetchFromGitHub {
    owner = "cinnyapp";
    repo = "cinny-desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/A/O42jwwK2iDV1IdRjOO8fE/AZ0h7UWAZZLozOqUWs=";
  };

  postPatch =
    let
      cinny' = cinny.override {
        conf = {
          hashRouter.enabled = true;
        };
      };
    in
    ''
      ${lib.getExe jq} \
        '.build.frontendDist = "${cinny'}" | del(.build.beforeBuildCommand) | .bundle.createUpdaterArtifacts = false' tauri.conf.json \
        | ${lib.getExe' moreutils "sponge"} tauri.conf.json
    '';

  nativeBuildInputs = [
    cargo-tauri.hook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    desktop-file-utils
    pkg-config
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-EF8gpfeZasazq0NKrjItt4bkgautQjYjEegf1OlWLOw=";

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/bin"
      makeWrapper "$out/Applications/Cinny.app/Contents/MacOS/Cinny" "$out/bin/cinny"
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      desktop-file-edit \
        --set-comment "Yet another matrix client for desktop" \
        --set-key="Categories" --set-value="Network;InstantMessaging;" \
        $out/share/applications/Cinny.desktop
    '';

  buildFeatures = [ "custom-protocol" ];
  buildNoDefaultFeatures = true;
  sourceRoot = "${finalAttrs.src.name}/src-tauri";

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script { attrPath = "cinny-unwrapped"; })
      (nix-update-script { })
    ];
  };

  meta = {
    description = "Yet another matrix client for desktop";
    homepage = "https://github.com/cinnyapp/cinny-desktop";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      qyriad
      rebmit
      ryand56
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "cinny";
  };
})
