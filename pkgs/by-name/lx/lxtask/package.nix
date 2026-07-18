{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gitUpdater,
  gtk3,
  intltool,
  libintl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxtask";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxtask";
    tag = finalAttrs.version;
    hash = "sha256-BI50jV/17jGX91rcmg98+gkoy35oNpdSSaVDLyagbIc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    pkg-config
  ];

  buildInputs = [
    gtk3
    libintl
  ];

  configureFlags = [ "--enable-gtk3" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Lightweight and desktop independent task manager";

    longDescription = ''
      LXTask is a lightweight task manager derived from xfce4 task manager
      with all xfce4 dependencies removed, some bugs fixed, and some
      improvement of UI. Although being part of LXDE, the Lightweight X11
      Desktop Environment, it's totally desktop independent and only
      requires pure GTK.
    '';

    homepage = "https://lxde.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "lxtask";
  };
})
