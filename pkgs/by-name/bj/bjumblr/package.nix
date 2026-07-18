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
  pname = "bjumblr";
  version = "1.6.8";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BJumblr";
    tag = finalAttrs.version;
    sha256 = "sha256-qSoGmWUGaMjx/bkiCJ/qb4LBbuFPXXlJ0e9hrFBXzwE=";
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
    description = "Pattern-controlled audio stream / sample re-sequencer LV2 plugin";
    homepage = "https://github.com/sjaehn/BJumblr";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
