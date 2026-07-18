{
  lib,
  fetchFromGitHub,
  # Wrapper
  addDriverRunpath,
  # buildInputs
  bashNonInteractive,
  glib-networking,
  gtk4,
  libadwaita,
  libepoxy,
  libsoup_3,
  mpv,
  nix-update-script,
  nodejs,
  # nativeBuildInputs
  pkg-config,
  rustPlatform,
  versionCheckHook,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stremio-linux-shell";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "Stremio";
    repo = "stremio-linux-shell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jo+9KDX/a46jPTmYhiFNgp5fDKhoAsML/+m7u3ituEQ=";
  };

  patches = [
    ./out-path.patch
  ];

  postPatch = ''
    substituteInPlace data/com.stremio.Stremio.service data/stremio.sh build.rs \
      --subst-var out
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    bashNonInteractive
    glib-networking
    gtk4
    libadwaita
    libepoxy
    libsoup_3
    mpv
    webkitgtk_6_0
  ];

  cargoHash = "sha256-hZ9neZD+aB7bth4UTsWJXIKGSbo/c3wZRtfOIp7LvwY=";

  postInstall = ''
    install -Dm644 data/icons/com.stremio.Stremio.svg $out/share/icons/hicolor/scalable/apps/com.stremio.Stremio.svg
    install -Dm644 data/com.stremio.Stremio.desktop $out/share/applications/com.stremio.Stremio.desktop
    install -Dm644 data/com.stremio.Stremio.metainfo.xml $out/share/metainfo/com.stremio.Stremio.metainfo.xml
    install -Dm644 data/com.stremio.Stremio.service $out/share/dbus-1/services/com.stremio.Stremio.service
    install -Dm644 data/server.js $out/libexec/stremio/server.js
    install -Dm755 data/stremio.sh $out/bin/stremio
    install -Dm644 LICENSE $out/share/licenses/stremio/LICENSE

    mv $out/bin/stremio-linux-shell $out/libexec/stremio/stremio
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # Node.js is required to run `server.js`
  # Add to `wrapGApp` arguments to avoid two layers of wrapping.
  preFixup = ''
    wrapGApp $out/bin/stremio \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ addDriverRunpath.driverLink ]}" \
      --prefix PATH : "${lib.makeBinPath [ nodejs ]}" \
      --prefix ANV_DEBUG : "video-decode,video-encode" \
      --prefix LC_NUMERIC : "C" \
      --prefix SERVER_PATH : "$out/libexec/stremio/server.js"
  '';

  __structuredAttrs = true;
  # Avoid also wrapping `$out/libexec/stremio/stremio`
  dontWrapGApps = true;
  versionCheckProgramArg = "--version";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^v([0-9.]+)$" ];
    };
  };

  meta = {
    description = "Client for Stremio on Linux";
    homepage = "https://www.stremio.com/";
    changelog = "https://github.com/Stremio/stremio-linux-shell/releases/tag/${finalAttrs.src.tag}";

    license =
      with lib.licenses;
      AND [
        gpl3Only
        unfree # server.js
      ];

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      obfuscatedCode # server.js
    ];

    maintainers = with lib.maintainers; [
      thunze
      fazzi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "stremio";
    downloadPage = "https://github.com/Stremio/stremio-linux-shell";
  };
})
