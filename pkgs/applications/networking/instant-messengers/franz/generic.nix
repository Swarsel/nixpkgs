{
  lib,
  stdenv,
  alsa-lib,
  atk,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libappindicator-gtk3,
  libgbm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  pipewire,
  udev,
  wrapGAppsHook3,
  xdg-utils,
}:

# Helper function for building a derivation for Franz and forks.

{
  meta,
  name,
  pname,
  src,
  version,
  extraBuildInputs ? [ ],
  ...
}@args:
let
  cleanedArgs = removeAttrs args [
    "pname"
    "name"
    "version"
    "src"
    "meta"
    "extraBuildInputs"
  ];
in
stdenv.mkDerivation (
  rec {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      wrapGAppsHook3
      dpkg
    ];

    buildInputs =
      extraBuildInputs
      ++ [
        libxi
        libxcursor
        libxdamage
        libxrandr
        libxcomposite
        libxext
        libxfixes
        libxrender
        libx11
        libxtst
        libxscrnsaver
      ]
      ++ [
        libgbm
        gtk3
        atk
        glib
        pango
        gdk-pixbuf
        cairo
        freetype
        fontconfig
        dbus
        nss
        nspr
        alsa-lib
        cups
        expat
        stdenv.cc.cc
        pipewire
        libpulseaudio
      ];

    installPhase = ''
      mkdir -p $out/bin
      cp -r opt $out
      ln -s $out/opt/${name}/${pname} $out/bin

      # Provide desktop item and icon.
      cp -r usr/share $out
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace /opt/${name}/${pname} ${pname}
    '';

    postFixup = ''
      # make xdg-open overridable at runtime
      wrapProgramShell $out/opt/${name}/${pname} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeDependencies}" \
        --suffix PATH : ${xdg-utils}/bin \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true}}" \
        "''${gappsWrapperArgs[@]}"
    '';

    # Don't remove runtime deps.
    dontPatchELF = true;
    dontWrapGApps = true;

    runtimeDependencies = [
      libglvnd
      (lib.getLib stdenv.cc.cc)
      (lib.getLib udev)
      libnotify
      libappindicator-gtk3
      pipewire
      libpulseaudio
    ];
  }
  // cleanedArgs
)
