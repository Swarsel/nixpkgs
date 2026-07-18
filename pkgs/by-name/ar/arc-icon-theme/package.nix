{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  autoreconfHook,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  moka-icon-theme,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "arc-icon-theme";
  version = "20161122";

  src = fetchFromGitHub {
    owner = "horst3180";
    repo = "arc-icon-theme";
    tag = finalAttrs.version;
    hash = "sha256-TfYtzwo69AC5hHbzEqB4r5Muqvn/eghCGSlmjMCFA7I=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk3
  ];

  propagatedBuildInputs = [
    moka-icon-theme
    adwaita-icon-theme
    gnome-icon-theme
    hicolor-icon-theme
  ];

  postFixup = "gtk-update-icon-cache $out/share/icons/Arc";
  dontDropIconThemeCache = true;

  meta = {
    description = "Arc icon theme";
    homepage = "https://github.com/horst3180/arc-icon-theme";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ romildo ];
    # moka-icon-theme dependency is restricted to linux
    platforms = lib.platforms.linux;
  };
})
