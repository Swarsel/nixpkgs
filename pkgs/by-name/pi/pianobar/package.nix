{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  ffmpeg,
  json_c,
  libao,
  libgcrypt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pianobar";
  version = "2024.12.21";

  src = fetchFromGitHub {
    owner = "PromyLOPh";
    repo = "pianobar";
    tag = finalAttrs.version;
    hash = "sha256-efmzc37Z6fjEOSzc29mowlaq3qEhyy3ta/gWMpuDJ+w=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libao
    json_c
    libgcrypt
    ffmpeg
    curl
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Console front-end for Pandora.com";
    homepage = "https://6xq.net/pianobar/";
    changelog = "https://github.com/PromyLOPh/pianobar/raw/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.mit; # expat version
    platforms = lib.platforms.unix;
    mainProgram = "pianobar";
  };
})
