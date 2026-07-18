{
  lib,
  stdenv,
  fetchFromGitHub,
  anthy,
  gtk2,
  gtk3,
  libchewing,
  libxtst,
  pkg-config,
  qt5,
  unixtools,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hime";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "hime-ime";
    repo = "hime";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fCqet+foQjI+LpTQ/6Egup1GzXELlL2hgbh0dCKLwPI=";
  };

  nativeBuildInputs = [
    which
    pkg-config
    unixtools.whereis
  ];

  buildInputs = [
    libxtst
    gtk2
    gtk3
    qt5.qtbase
    libchewing
    anthy
  ];

  configureFlags = [
    "--disable-lib64"
    "--disable-qt5-immodule"
  ];

  preConfigure = "patchShebangs configure";

  postFixup = ''
    hime_rpath=$(patchelf --print-rpath $out/bin/hime)
    patchelf --set-rpath $out/lib/hime:$hime_rpath $out/bin/hime
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Useful input method engine for Asia region";
    homepage = "http://hime-ime.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ yanganto ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/hime-ime/hime/downloads";
  };
})
