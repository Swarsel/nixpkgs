{
  lib,
  stdenv,
  fetchFromGitHub,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "midi-trigger";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "unclechu";
    repo = "MIDI-Trigger";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-tMnN8mTd6Bm46ZIDy0JPSVe77xCZws2XwQLQexDWPgU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ lv2 ];

  makeFlags = [
    "CXX=cc"
    "BUILD_DIR=."
  ];

  installPhase = ''
    mkdir -p "$out/lib/lv2"
    mv midi-trigger.lv2 "$out/lib/lv2"
  '';

  meta = {
    description = "LV2 plugin which generates MIDI notes by detected audio signal peaks";
    homepage = "https://github.com/unclechu/MIDI-Trigger";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ unclechu ];
    platforms = lib.platforms.unix;
  };
})
