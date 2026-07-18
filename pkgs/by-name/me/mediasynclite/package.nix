{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  jansson,
  openssl,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mediasynclite";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "iBroadcastMediaServices";
    repo = "MediaSyncLiteLinux";
    rev = finalAttrs.version;
    hash = "sha256-vnajWmQfKJ3ff/O4IROXiRAKEGu/6EMX9/oApwcwoaU=";
  };

  postPatch = ''
    substitute ./src/ibmsl.c ./src/ibmsl.c --subst-var out
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gsettings-desktop-schemas
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    curl
    glib
    gtk3
    openssl
    jansson
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Linux-native graphical uploader for iBroadcast";
    homepage = "https://github.com/iBroadcastMediaServices/MediaSyncLiteLinux";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tobz619 ];
    downloadPage = "https://github.com/tobz619/MediaSyncLiteLinuxNix";
  };
})
