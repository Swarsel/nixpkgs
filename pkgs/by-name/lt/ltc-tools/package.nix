{
  lib,
  stdenv,
  fetchFromGitHub,
  jack2,
  libltc,
  libsndfile,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ltc-tools";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "x42";
    repo = "ltc-tools";
    rev = "v${finalAttrs.version}";
    sha256 = "0vp25b970r1hv5ndzs4di63rgwnl31jfaj3jz5dka276kx34q4al";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libltc
    libsndfile
    jack2
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Tools to deal with linear-timecode (LTC)";
    homepage = "https://github.com/x42/ltc-tools";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ tg-x ];
    platforms = lib.platforms.unix;
  };
})
