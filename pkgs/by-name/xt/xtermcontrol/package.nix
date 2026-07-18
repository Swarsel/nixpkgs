{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xtermcontrol";
  version = "3.10";

  src = fetchurl {
    url = "https://thrysoee.dk/xtermcontrol/xtermcontrol-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-Prl7HZ2KrhutT+LEHKOj27ENLWfmykWZqh9jGkBQPe4=";
  };

  meta = {
    description = "Enables dynamic control of xterm properties";

    longDescription = ''
      Enables dynamic control of xterm properties.
      It makes it easy to change colors, title, font and geometry of a running xterm, as well as to report the current settings of these properties.
      Window manipulations de-/iconify, raise/lower, maximize/restore and reset are also supported.
      To complete the feature set; xtermcontrol lets advanced users issue any xterm control sequence of their choosing.
    '';

    homepage = "http://thrysoee.dk/xtermcontrol";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.derchris ];
    platforms = lib.platforms.unix;
    mainProgram = "xtermcontrol";
  };
})
