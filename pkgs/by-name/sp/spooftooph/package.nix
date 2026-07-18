{
  lib,
  stdenv,
  fetchurl,
  bluez,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spooftooph";
  version = "0.5.2";

  src = fetchurl {
    url = "mirror://sourceforge/project/spooftooph/spooftooph-${finalAttrs.version}/spooftooph-${finalAttrs.version}.tar.gz";
    hash = "sha256-JH5+fHpe83NJV9AR5MXKnrwaTqz4s2BGAcczbddVNHw=";
  };

  buildInputs = [
    bluez
    ncurses
  ];

  makeFlags = [ "BIN=$(out)/bin" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-incompatible-pointer-types";

  preInstall = ''
    mkdir -p $out/bin
  '';

  meta = {
    description = "Automate spoofing or clone Bluetooth device Name, Class, and Address";
    homepage = "https://sourceforge.net/projects/spooftooph";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "spooftooph";
  };
})
