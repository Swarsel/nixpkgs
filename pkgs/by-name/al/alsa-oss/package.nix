{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  gettext,
  libsamplerate,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alsa-oss";
  version = "1.1.8";

  src = fetchurl {
    url = "mirror://alsa/oss-lib/alsa-oss-${finalAttrs.version}.tar.bz2";
    hash = "sha256-ZK3O9ZJ+hI0uAk5kxL+FtvOVlk2ZdOxhkFrky4011o4=";
  };

  nativeBuildInputs = [ gettext ];

  buildInputs = [
    alsa-lib
    ncurses
    libsamplerate
  ];

  configureFlags = [ "--disable-xmlto" ];
  installFlags = [ "ASOUND_STATE_DIR=$(TMPDIR)/dummy" ];

  meta = {
    description = "ALSA, the Advanced Linux Sound Architecture alsa-oss emulation";

    longDescription = ''
      The Advanced Linux Sound Architecture (ALSA) provides audio and
      MIDI functionality to the Linux-based operating system.
    '';

    homepage = "http://www.alsa-project.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "aoss";
  };
})
