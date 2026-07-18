{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  glib-networking,
  gtk3,
  libappindicator,
  libnotify,
  libsoup_3,
  makeBinaryWrapper,
  makeWrapper,
  mpv-unwrapped,
  undmg,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xdg-user-dirs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spotube";
  version = "5.1.2";
  src = finalAttrs.passthru.sources.${stdenv.hostPlatform.system};

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
      dpkg
      makeWrapper
      wrapGAppsHook3
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      undmg
      makeBinaryWrapper
    ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    gtk3
    libappindicator
    libnotify
    libsoup_3
    webkitgtk_4_1
  ];

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out
    cp -r usr/* $out
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r Spotube.app $out/Applications
    makeBinaryWrapper $out/Applications/Spotube.app/Contents/MacOS/Spotube $out/bin/spotube
  ''
  + ''
    runHook postInstall
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    makeWrapper $out/share/spotube/spotube $out/bin/spotube \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : $out/share/spotube/lib:${lib.makeLibraryPath [ mpv-unwrapped ]} \
      --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]}
  '';

  dontWrapGApps = true;
  sourceRoot = lib.optionalString stdenv.hostPlatform.isDarwin ".";

  passthru.sources =
    let
      fetchArtifact =
        { hash, suffix }:
        fetchurl {
          inherit hash;
          name = "Spotube-${finalAttrs.version}-${suffix}";
          url = "https://github.com/KRTirtho/spotube/releases/download/v${finalAttrs.version}/Spotube-${suffix}";
        };
    in
    {
      "aarch64-darwin" = fetchArtifact {
        hash = "sha256-J2J9/UQZAECvGmumqGzcRFA5kpakOmFpQKlK5oesCRM=";
        suffix = "macos-universal.dmg";
      };

      "aarch64-linux" = fetchArtifact {
        hash = "sha256-cb9qPNJ1wB3zURvBCLEJIr+L4BGYwtgjAezSRm4QQDE=";
        suffix = "linux-aarch64.deb";
      };

      "x86_64-linux" = fetchArtifact {
        hash = "sha256-FEb5mPmGOAMw4nnFJ0kC+ymg4zBdUXWjvIO0sGOS6M0=";
        suffix = "linux-x86_64.deb";
      };
    };

  meta = {
    description = "Open source, cross-platform Spotify client compatible across multiple platforms";

    longDescription = ''
      Spotube is an open source, cross-platform Spotify client compatible across
      multiple platforms utilizing Spotify's data API and YouTube (or Piped.video or JioSaavn)
      as an audio source, eliminating the need for Spotify Premium
    '';

    homepage = "https://spotube.krtirtho.dev/";
    license = lib.licenses.bsdOriginal;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.attrNames finalAttrs.passthru.sources;
    mainProgram = "spotube";
    downloadPage = "https://github.com/KRTirtho/spotube/releases";
  };
})
