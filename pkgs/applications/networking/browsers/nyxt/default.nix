{
  lib,
  stdenv,
  cairo,
  fetchzip,
  gdk-pixbuf,
  glib,
  glib-networking,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst-libav,
  gst-plugins-bad,
  gst-plugins-base,
  gst-plugins-good,
  gst-plugins-ugly,
  gstreamer,
  gtk3,
  libfixposix,
  nix-update-script,
  nixosTests,
  openssl,
  pango,
  pkg-config,
  sbcl,
  sqlite,
  testers,
  webkitgtk_4_1,
  wl-clipboard,
  wrapGAppsHook3,
  xclip,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nyxt";
  version = "3.12.0";

  src = fetchzip {
    url = "https://github.com/atlas-engineer/nyxt/releases/download/${finalAttrs.version}/nyxt-${finalAttrs.version}-source-with-submodules.tar.xz";
    hash = "sha256-T5p3OaWp28rny81ggdE9iXffmuh6wt6XSuteTOT8FLI=";
    stripRoot = false;
  };

  nativeBuildInputs = [ wrapGAppsHook3 ];

  buildInputs = [
    sbcl
    # for groveller
    pkg-config
    libfixposix
    # for gappsWrapper
    gobject-introspection
    gsettings-desktop-schemas
    glib-networking
    gtk3
    gstreamer
    gst-libav
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];

  # don't refresh from git
  makeFlags = [
    "all"
    "NYXT_SUBMODULES=false"
  ];

  # for cffi
  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    glib
    gobject-introspection
    gdk-pixbuf
    cairo
    pango
    gtk3
    webkitgtk_4_1
    openssl
    sqlite
    libfixposix
  ];

  postConfigure = ''
    export CL_SOURCE_REGISTRY="$(pwd)/_build//"
    export ASDF_OUTPUT_TRANSLATIONS="$(pwd):$(pwd)"
    export PREFIX="$out"
    export NYXT_VERSION="$version"
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH")
    gappsWrapperArgs+=(--prefix PATH : "${
      lib.makeBinPath [
        xdg-utils
        xclip
        wl-clipboard
      ]
    }")
  '';

  # prevent corrupting core in exe
  dontStrip = true;

  passthru = {
    tests = { inherit (nixosTests) nyxt; };
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Infinitely extensible web-browser (with Lisp development files using WebKitGTK platform port)";
    homepage = "https://nyxt.atlas.engineer";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      lewo
      dariof4
    ];

    platforms = lib.platforms.all;
    mainProgram = "nyxt";
  };
})
