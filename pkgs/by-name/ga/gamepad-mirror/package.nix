{
  lib,
  stdenv,
  appstream,
  cmake,
  desktop-file-utils,
  fetchFromCodeberg,
  gdk-pixbuf,
  gettext,
  gjs,
  glib,
  gobject-introspection,
  graphene,
  gtk4,
  harfbuzz,
  libadwaita,
  libgudev,
  libmanette,
  meson,
  ninja,
  pango,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gamepad-mirror";
  version = "0.3-unstable-2025-10-18";

  src = fetchFromCodeberg {
    owner = "vendillah";
    repo = "GamepadMirror";
    rev = "aa86d55f21b4d206eab61d0bf7cd9ccafc8aa607";
    hash = "sha256-ZpBsJRQWRoAwp2G6CzVMtb+j71F0BbJuQ8vUnoZfEgc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    wrapGAppsHook4
    pkg-config
    cmake
    ninja
    gettext # msgfmt
    appstream
    gjs
    desktop-file-utils # desktop-file-validate
  ];

  buildInputs = [
    gjs
    glib
    gtk4
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    (
      set -x
      env -i $out/bin/${finalAttrs.meta.mainProgram} --help
    )
    runHook postInstallCheck
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GI_TYPELIB_PATH : ${
        lib.makeSearchPathOutput "out" "lib/girepository-1.0" finalAttrs.passthru.giTypelibInputs
      }
    )
  '';

  # tries to look for .foobar-wrapped.{data,src}.gresource, switch to the hardcoded one
  # TODO: why doesn't --inherit-argv0 work?
  postFixup = ''
    mv -v $out/share/gamepad-mirror/{page.codeberg.vendillah.GamepadMirror,gamepad-mirror}.data.gresource
    mv -v $out/share/gamepad-mirror/{page.codeberg.vendillah.GamepadMirror,gamepad-mirror}.src.gresource
  '';

  __structuredAttrs = true;

  passthru.giTypelibInputs = [
    glib
    gtk4
    graphene
    gobject-introspection
    pango
    harfbuzz
    gdk-pixbuf
    libadwaita
    libmanette
    libgudev
  ];

  meta = {
    description = "Small Adwaita application to show game pad inputs using libmanette";
    homepage = "https://codeberg.org/vendillah/GamepadMirror";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ pbsds ];
    platforms = lib.platforms.linux;
    mainProgram = "page.codeberg.vendillah.GamepadMirror";
  };
})
