{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gnome-themes-extra,
  gtk-engine-murrine,
  gtk3,
  hicolor-icon-theme,
  humanity-icon-theme,
  meson,
  ninja,
  pkg-config,
  python3,
  sassc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yaru";
  version = "25.10.3";

  src = fetchFromGitHub {
    owner = "ubuntu";
    repo = "yaru";
    rev = finalAttrs.version;
    hash = "sha256-3cSVPObfmr62S6yTD2c8AO3s7lxb9KFVuYSydTIJ1jE=";
  };

  postPatch = "patchShebangs .";

  nativeBuildInputs = [
    meson
    sassc
    pkg-config
    glib
    ninja
    python3
  ];

  buildInputs = [
    gtk3
    gnome-themes-extra
  ];

  propagatedBuildInputs = [
    humanity-icon-theme
    hicolor-icon-theme
  ];

  dontDropIconThemeCache = true;
  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "Ubuntu community theme 'yaru' - default Ubuntu theme since 18.10";
    homepage = "https://github.com/ubuntu/yaru";

    license = with lib.licenses; [
      cc-by-sa-40
      gpl3Plus
      lgpl21Only
      lgpl3Only
    ];

    maintainers = with lib.maintainers; [ moni ];
    platforms = lib.platforms.linux;
  };
})
