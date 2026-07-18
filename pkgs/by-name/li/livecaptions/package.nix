{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  appstream-glib,
  cmake,
  desktop-file-utils,
  libadwaita,
  libpulseaudio,
  libx11,
  meson,
  ninja,
  onnxruntime,
  pkg-config,
  wrapGAppsHook4,
}:
let
  aprilAsr = fetchFromGitHub {
    hash = "sha256-/cOZ2EcZu/Br9v0ComxnOegcEtlC9e8FYt3XHfah7mE=";
    name = "april-asr";
    owner = "abb128";
    repo = "april-asr";
    rev = "3308e68442664552de593957cad0fa443ea183dd";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "livecaptions";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "abb128";
    repo = "LiveCaptions";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bLWJQgZopuQ0t2pexazUTj1+C2weRMrL3PUhIHZ0W5M=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    appstream-glib # appstreamcli
    desktop-file-utils # update-desktop-database
    wrapGAppsHook4
  ];

  buildInputs = [
    onnxruntime
    libadwaita
    libpulseaudio
    libx11
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --set APRIL_MODEL_PATH ${finalAttrs.model}
    )
  '';

  model = fetchurl {
    hash = "sha256-d+uV0PpPdwijfoaMImUwHubELcsl5jymPuo9nLrbwfM=";
    name = "april-english-dev-01110_en.april";
    url = "https://april.sapples.net/april-english-dev-01110_en.april";
  };

  postUnpack = ''
    rm -r source/subprojects/april-asr
    ln -s ${aprilAsr} source/subprojects/april-asr
  '';

  meta = {
    description = "Linux Desktop application that provides live captioning";
    homepage = "https://github.com/abb128/LiveCaptions";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = lib.platforms.linux;
    mainProgram = "livecaptions";
  };
})
