{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cpio,
  libsndfile,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bvibratr";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BVibratr";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-V3cy+JlpBjCYr4eyrr9fTuaA7bmi8A2SP5KA4o1qQDU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    cpio
    lv2
    libsndfile
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Flavoured vibrato as an instrument LV2 plugin";
    homepage = "https://github.com/sjaehn/BVibratr";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
