{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abcmidi";
  version = "2026.06.16";

  src = fetchFromGitHub {
    owner = "sshlien";
    repo = "abcmidi";
    tag = finalAttrs.version;
    hash = "sha256-GkCvIZSspqwV3Q0+GZh08pQt5RFgPTdJ4fS9OaV+jXs=";
  };

  # TODO: remove once https://github.com/sshlien/abcmidi/pull/15 merged
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  meta = {
    description = "Utilities for converting between abc and MIDI";
    homepage = "https://abc.sourceforge.net/abcMIDI/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.unix;
    downloadPage = "https://ifdo.ca/~seymour/runabc/top.html";
  };
})
