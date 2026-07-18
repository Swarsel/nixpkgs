{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  ncurses,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sc";
  version = "7.16_1.2.0";

  src = fetchFromGitHub {
    owner = "n-t-roff";
    repo = "sc";
    tag = finalAttrs.version;
    hash = "sha256-4Ma3JWrK2udMLEAUboBGzfLTQjX+TdXG7ygvhS14BiM=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ bison ];
  buildInputs = [ ncurses ];
  # Non-standard configure script
  configurePhase = "./configure";
  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Curses-based spreadsheet calculator";

    longDescription = ''
      This is a fork of the old sc-7.16 application with attention paid to
      reduced compiler warnings, bugfixes, and functionality improvements
      (e.g. mouse suport, configurability via .scrc).
      See CHANGES-git or README.md for a full list of changes.
    '';

    homepage = "https://github.com/n-t-roff/sc";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.claes ];
    platforms = lib.platforms.unix;
  };
})
