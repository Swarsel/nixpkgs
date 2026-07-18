{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bash-completion,
  libexif,
  libjpeg,
  libpng,
  libwebp,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jp2a";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "Talinx";
    repo = "jp2a";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GvPRLYrqZyzk24RmJJ1VcnXo6uda50qqqRA/pioPm5Q=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    pkg-config
    bash-completion
  ];

  buildInputs = [
    libjpeg
    libpng
    ncurses
    libwebp
    libexif
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "bashcompdir=\${out}/share/bash-completion/completions" ];

  meta = {
    description = "Small utility that converts JPG images to ASCII";
    homepage = "https://github.com/Talinx/jp2a";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.FlorianFranzen ];
    platforms = lib.platforms.unix;
    mainProgram = "jp2a";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
