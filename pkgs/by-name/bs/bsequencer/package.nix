{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libx11,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bsequencer";
  version = "1.8.10";

  src = fetchFromGitHub {
    owner = "sjaehn";
    repo = "BSEQuencer";
    tag = finalAttrs.version;
    sha256 = "sha256-1PSICm5mw37nO3gkHA9MNUH+CFULeOZURjimYEA/dXA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    cairo
    lv2
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Multi channel MIDI step sequencer LV2 plugin";
    homepage = "https://github.com/sjaehn/BSEQuencer";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
