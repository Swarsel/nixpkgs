{
  lib,
  stdenv,
  fetchFromGitLab,
  perl,
  xkeyboard_config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ckbcomp";
  version = "1.242";

  src = fetchFromGitLab {
    owner = "installer-team";
    repo = "console-setup";
    rev = finalAttrs.version;
    sha256 = "sha256-5PV1Mbg7ZGQsotwnBVz8DI77Y8ULCnoTANqBLlP3YrE=";
    domain = "salsa.debian.org";
  };

  buildInputs = [ perl ];

  installPhase = ''
    install -Dm0555 -t $out/bin Keyboard/ckbcomp
    install -Dm0444 -t $out/share/man/man1 man/ckbcomp.1
  '';

  dontBuild = true;

  patchPhase = ''
    substituteInPlace Keyboard/ckbcomp --replace "/usr/share/X11/xkb" "${xkeyboard_config}/share/X11/xkb"
    substituteInPlace Keyboard/ckbcomp --replace "rules = 'xorg'" "rules = 'base'"
  '';

  meta = {
    description = "Compiles a XKB keyboard description to a keymap suitable for loadkeys";
    homepage = "https://salsa.debian.org/installer-team/console-setup";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ckbcomp";
  };
})
