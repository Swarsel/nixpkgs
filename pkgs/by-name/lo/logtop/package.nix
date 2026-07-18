{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  pkg-config,
  uthash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "logtop";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "JulienPalard";
    repo = "logtop";
    rev = "logtop-${finalAttrs.version}";
    sha256 = "1f8vk9gybldxvc0kwz38jxmwvzwangsvlfslpsx8zf04nvbkqi12";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    ncurses
    uthash
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  postConfigure = ''
    substituteInPlace Makefile --replace /usr ""
  '';

  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Displays a real-time count of strings received from stdin";

    longDescription = ''
      logtop displays a real-time count of strings received from stdin.
      It can be useful in some cases, like getting the IP flooding your
      server or the top buzzing article of your blog
    '';

    homepage = "https://github.com/JulienPalard/logtop";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.starcraft66 ];
    platforms = lib.platforms.unix;
    mainProgram = "logtop";
  };
})
