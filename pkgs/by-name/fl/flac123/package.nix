{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  flac,
  libao,
  libogg,
  popt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flac123";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "flac123";
    repo = "flac123";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LtL69t2r9TlIkpQWZLge8ib7NZ5rvLW6JllG2UM16Kw=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    flac
    libao
    libogg
    popt
  ];

  meta = {
    description = "Command-line program for playing FLAC audio files";
    homepage = "https://github.com/flac123/flac123";
    changelog = "https://github.com/flac123/flac123/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ kiike ];
    platforms = lib.platforms.unix;
    mainProgram = "flac123";
  };
})
