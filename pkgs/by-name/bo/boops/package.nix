{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libsndfile,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "boops";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BOops";
    tag = finalAttrs.version;
    sha256 = "0nvpawk58g189z96xnjs4pyri5az3ckdi9mhi0i9s0a7k4gdkarr";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    lv2
    libsndfile
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Sound glitch effect sequencer LV2 plugin";
    homepage = "https://github.com/sjaehn/BOops";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
