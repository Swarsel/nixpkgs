{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildNpmPackage,
  cargo-tauri,
  dbip-country-lite,
  glib,
  libayatana-appindicator,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
}:
let
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "openscopeproject";
    repo = "TrguiNG";
    tag = "v${version}";
    hash = "sha256-IcOkKYxkU7c+sIPcig10sR1L66xb7oYim7KALWsz9rQ=";
  };

  meta = {
    description = "Remote GUI for Transmission torrent daemon";
    homepage = "https://github.com/openscopeproject/TrguiNG";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ambroisie ];
  };

  frontend = buildNpmPackage (finalAttrs: {
    inherit version src;
    pname = "TrguiNG-frontend";
    npmDepsHash = "sha256-5ev3Aj1fIy/qvw543OwdGTTWmdqbpobJdTGlX5B2VD0=";
    env.TRGUING_VERSION = finalAttrs.version;

    installPhase = ''
      runHook preInstall

      cp -r dist/ $out

      runHook postInstall
    '';

    npmBuildScript = "webpack-prod";

    meta = meta // {
      description = "Web UI for Transmission torrent daemon";
    };
  });
in

rustPlatform.buildRustPackage (finalAttrs: {
  inherit version src;
  pname = "TrguiNG";

  postPatch = ''
    cp ${dbip-country-lite}/share/dbip/dbip-country-lite.mmdb src-tauri/dbip.mmdb

    # Copy pre-built frontend and remove `beforeBuildCommand` to build it
    cp -r ${finalAttrs.passthru.frontend} dist/
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"npm run webpack-prod"' '""'
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    glib
    libayatana-appindicator
    webkitgtk_4_1
  ];

  cargoHash = "sha256-coyKwBz26Ohl/+gJS8X+kTYOhaQ1pfY7/rbupF+CaUY=";
  buildAndTestSubdir = "src-tauri";
  cargoRoot = "src-tauri";

  passthru = {
    inherit frontend;

    updateScript = nix-update-script {
      extraArgs = [
        "-s"
        "frontend"
      ];
    };
  };

  meta = meta // {
    mainProgram = "TrguiNG";
  };
})
