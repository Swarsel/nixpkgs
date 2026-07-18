{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  scanmem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ugtrain";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "ugtrain";
    repo = "ugtrain";
    rev = "v${finalAttrs.version}";
    sha256 = "0pw9lm8y83mda7x39874ax2147818h1wcibi83pd2x4rp1hjbkkn";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    scanmem
  ];

  meta = {
    description = "Universal Elite Game Trainer for CLI (Linux game trainer research project)";
    homepage = "https://github.com/ugtrain/ugtrain";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mtrsk ];
    platforms = lib.platforms.linux;
  };
})
