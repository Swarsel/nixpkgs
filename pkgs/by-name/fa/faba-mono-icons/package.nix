{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  faba-icon-theme,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  moka-icon-theme,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "faba-mono-icons";
  version = "2016-04-30";

  src = fetchFromGitHub {
    owner = "snwh";
    repo = "faba-mono-icons";
    rev = "2006c5281eb988c799068734f289a85443800cda";
    sha256 = "0nisfl92y6hrbakp9qxi0ygayl6avkzrhwirg6854bwqjy2dvjv9";
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk3
  ];

  propagatedBuildInputs = [
    moka-icon-theme
    faba-icon-theme
    gnome-icon-theme
    hicolor-icon-theme
  ];

  postInstall = ''
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  dontDropIconThemeCache = true;

  meta = {
    description = "Full set of Faba monochrome panel icons";
    homepage = "https://snwh.org/moka";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ romildo ];
    # moka-icon-theme dependency is restricted to linux
    platforms = lib.platforms.linux;
  };
}
