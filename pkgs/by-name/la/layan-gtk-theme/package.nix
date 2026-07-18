{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk-engine-murrine,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "layan-gtk-theme";
  version = "2023-05-23";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "layan-gtk-theme";
    rev = finalAttrs.version;
    sha256 = "sha256-R8QxDMOXzDIfioAvvescLAu6NjJQ9zhf/niQTXZr+yA=";
  };

  postPatch = ''
    patchShebangs install.sh
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    unset name && ./install.sh -d $out/share/themes
    runHook postInstall
  '';

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "Flat Material Design theme for GTK 3, GTK 2 and Gnome-Shell";
    homepage = "https://github.com/vinceliuice/Layan-gtk-theme";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.vanilla ];
    platforms = lib.platforms.linux;
  };
})
