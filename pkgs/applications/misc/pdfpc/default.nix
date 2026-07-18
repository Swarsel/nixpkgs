{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  discount,
  gobject-introspection,
  gst-libav,
  gst-plugins-base,
  gst-plugins-good,
  gstreamer,
  gtk3,
  json-glib,
  libgee,
  libpthread-stubs,
  librsvg,
  libsoup_3,
  nix-update-script,
  pkg-config,
  poppler,
  qrencode,
  vala,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "pdfpc";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "pdfpc";
    repo = "pdfpc";
    rev = "v${version}";
    hash = "sha256-fPhCrn1ELC03/II+e021BUNJr1OKCBIcFCM7z+2Oo+s=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    vala
    # For setup hook
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs =
    let
      platformBuildInputs =
        if stdenv.hostPlatform.isDarwin then
          [ librsvg ]
        else
          [
            libpthread-stubs
            webkitgtk_4_1
          ];
    in
    [
      (gst-plugins-good.override { gtkSupport = true; })
      discount
      gst-libav
      gst-plugins-base
      gstreamer
      gtk3
      json-glib
      libgee
      libsoup_3
      poppler
      qrencode
    ]
    ++ platformBuildInputs;

  cmakeFlags = lib.optional stdenv.hostPlatform.isDarwin (lib.cmakeBool "MDVIEW" false);
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Presenter console with multi-monitor support for PDF files";
    homepage = "https://pdfpc.github.io/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.unix;
    mainProgram = "pdfpc";
  };

}
