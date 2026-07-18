{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  espeak-ng,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "wordbook";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "fushinari";
    repo = "Wordbook";
    tag = finalAttrs.version;
    hash = "sha256-oiAXSDJJtlV6EIHzi+jFv+Ym1XHCMLx9DN1YRiXZNzc=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PATH ":" "${lib.makeBinPath [ espeak-ng ]}"
      "''${gappsWrapperArgs[@]}"
    )
  '';

  dependencies = with python3.pkgs; [
    pygobject3
    wn
  ];

  # prevent double wrapping
  dontWrapGApps = true;
  pyproject = false; # Built with meson

  meta = {
    description = "Offline English-English dictionary application built for GNOME";
    homepage = "https://github.com/fushinari/Wordbook";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "wordbook";
  };
})
