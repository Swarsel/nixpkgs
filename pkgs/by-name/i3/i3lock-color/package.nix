{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairo,
  libev,
  libjpeg_turbo,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-util,
  libxkbcommon,
  libxkbfile,
  pam,
  pkg-config,
  xcbutilxrm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "i3lock-color";
  version = "2.13.c.5";

  src = fetchFromGitHub {
    owner = "PandorasFox";
    repo = "i3lock-color";
    tag = finalAttrs.version;
    hash = "sha256-fuLeglRif2bruyQRqiL3nm3q6qxoHcPdVdL+QjGBR/k=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libxcb
    libxcb-keysyms
    libxcb-image
    pam
    libx11
    libev
    cairo
    libxkbcommon
    libxkbfile
    libjpeg_turbo
    xcbutilxrm
    libxcb-util
  ];

  makeFlags = [ "all" ];

  preInstall = ''
    mkdir -p $out/share/man/man1
  '';

  postInstall = ''
    mv $out/bin/i3lock $out/bin/i3lock-color
    ln -s $out/bin/i3lock-color $out/bin/i3lock
    mv $out/share/man/man1/i3lock.1 $out/share/man/man1/i3lock-color.1
    sed -i 's/\(^\|\s\|"\)i3lock\(\s\|$\)/\1i3lock-color\2/g' $out/share/man/man1/i3lock-color.1
  '';

  installFlags = [
    "PREFIX=\${out}"
    "SYSCONFDIR=\${out}/etc"
    "MANDIR=\${out}/share/man"
  ];

  meta = {
    description = "Simple screen locker like slock, enhanced version with extra configuration options";

    longDescription = ''
      Simple screen locker. After locking, a colored background (default: white) or
      a configurable image is shown, and a ring-shaped unlock-indicator gives feedback
      for every keystroke. After entering your password, the screen is unlocked again.

      i3lock-color is forked from i3lock (https://i3wm.org/i3lock/) with the following
      enhancements / additional configuration options:

      - indicator:
        - shape: ring or bar
        - size: configurable
        - all colors: configurable
        - all texts: configurable
        - visibility: can be always visible, can be restricted to some screens

      - background: optionally show a blurred screen instead of a single color

      - more information: show text at configurable positions:
        - clock: time/date with configurable format
        - keyboard-layout
    '';

    homepage = "https://github.com/PandorasFox/i3lock-color";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ malyn ];
    platforms = lib.platforms.all;
    mainProgram = "i3lock-color";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
