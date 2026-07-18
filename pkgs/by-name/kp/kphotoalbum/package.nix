{
  lib,
  stdenv,
  fetchurl,
  exiv2,
  ffmpeg,
  kdePackages,
  libvlc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kphotoalbum";
  version = "6.1.0";

  src = fetchurl {
    url = "mirror://kde/stable/kphotoalbum/${finalAttrs.version}/kphotoalbum-${finalAttrs.version}.tar.xz";
    hash = "sha256-fznB/B2VriB+Wt6ZxrPrNoJP45AuK1vV4ONpAHYwUlY=";
  };

  nativeBuildInputs = [
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    exiv2
    libvlc
  ];

  # not sure if we really need phonon when we have vlc, but on KDE it's bound to
  # be on the system anyway, so there is no real harm including it
  propagatedBuildInputs = with kdePackages; [
    kconfig
    kiconthemes
    kio
    kxmlgui
    phonon
    purpose
    libkdcraw
  ];

  env.LANG = "C.UTF-8";

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
  ];

  meta = {
    inherit (kdePackages.kconfig.meta) platforms;
    description = "Efficient image organization and indexing";
    homepage = "https://www.kphotoalbum.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
})
