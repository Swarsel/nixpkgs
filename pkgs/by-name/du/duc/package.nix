{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
  pkg-config,
  tokyocabinet,
  cairo ? null,
  enableCairo ? stdenv.hostPlatform.isLinux,
  pango ? null,
}:

assert enableCairo -> cairo != null && pango != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "duc";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "duc";
    rev = finalAttrs.version;
    sha256 = "sha256-hZ8bhPXS/trt6ZePjfuwx8PEfv0xCBqSJxRonLB7Ui0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    tokyocabinet
    ncurses
  ]
  ++ lib.optionals enableCairo [
    cairo
    pango
  ];

  configureFlags = lib.optionals (!enableCairo) [
    "--disable-x11"
    "--disable-cairo"
  ];

  meta = {
    description = "Collection of tools for inspecting and visualizing disk usage";
    homepage = "http://duc.zevv.nl/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "duc";
  };
})
