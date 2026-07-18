{
  lib,
  fetchurl,
  fetchFromGitHub,
  canto-daemon,
  ncurses,
  python3Packages,
  readline,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "canto-curses";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "themoken";
    repo = "canto-curses";
    rev = "v${finalAttrs.version}";
    sha256 = "1vzb9n1j4gxigzll6654ln79lzbrrm6yy0lyazd9kldyl349b8sr";
  };

  # Fixes the issue found here https://github.com/themoken/canto-curses/issues/59
  patches = [
    (fetchurl {
      hash = "sha256-2TMNmwjUAGyenSDqxfI+U2hNeDZaj2CivfTfpX7CKgY=";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/canto-curses/-/raw/6daa56bc5baebb2444c368a8208666ef484a6fc0/fix-build.patch";
    })
  ];

  buildInputs = [
    readline
    ncurses
    canto-daemon
  ];

  propagatedBuildInputs = [ canto-daemon ];

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Ncurses-based console Atom/RSS feed reader";

    longDescription = ''
      Canto is an Atom/RSS feed reader for the console that is meant to be
      quick, concise, and colorful. It's meant to allow you to crank through
      feeds like you've never cranked before by providing a minimal, yet
      information packed interface. No navigating menus. No dense blocks of
      unreadable white text. An interface with almost infinite customization
      and extensibility using the excellent Python programming language.
    '';

    homepage = "https://codezen.org/canto-ng/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.devhell ];
    platforms = lib.platforms.linux;
    mainProgram = "canto-curses";
  };
})
