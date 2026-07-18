{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  gtk3,
  makeWrapper,
  ncurses,
  pkg-config,
  scoreDirectory ? "$HOME/.local/share",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dopewars";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "benmwebb";
    repo = "dopewars";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CpgqRYmrfOFxhC7yAS2OqRBi4r3Vesq3+7a0q5rc3vM=";
  };

  patches = [
    # remove the denied setting of setuid bit permission
    ./0001-remove_setuid.patch
    # fix compilation errors with gcc15
    ./0002-fix_gcc15.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    curl
    gtk3
    ncurses
  ];

  preConfigure = ''
    substituteInPlace po/Makefile.in.in \
      --replace-fail '$(GMSGFMT) -c --statistics --verbose' '$(GMSGFMT) --statistics --verbose'
  '';

  # run dopewars with -f so that it finds its scoreboard file in ~/.local/share
  postInstall = ''
    wrapProgram $out/bin/dopewars \
      --run 'mkdir -p ${scoreDirectory}' \
      --add-flags '-f ${scoreDirectory}/dopewars.sco'
  '';

  meta = {
    description = "Game simulating the life of a drug dealer in New York";
    homepage = "https://dopewars.sourceforge.io";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ geri1701 ];
    platforms = lib.platforms.unix;
    mainProgram = "dopewars";
  };
})
