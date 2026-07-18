{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  glib,
  graphviz,
  gtk3,
  intltool,
  itstool,
  lrzsz,
  pkg-config,
  vala,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moserial";
  version = "3.0.21";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "moserial";
    rev = "moserial_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    sha256 = "sha256-wfdI51ECqVNcUrIVjYBijf/yqpiwSQeMiKaVJSSma3k=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    itstool
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    graphviz
    yelp-tools
    gtk3
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ lrzsz ]}
    )
  '';

  meta = {
    description = "Clean, friendly gtk-based serial terminal for the gnome desktop";
    homepage = "https://gitlab.gnome.org/GNOME/moserial";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ linsui ];
    platforms = lib.platforms.linux;
    mainProgram = "moserial";
  };
})
