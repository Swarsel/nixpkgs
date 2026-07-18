{
  lib,
  stdenv,
  fetchFromGitHub,
  ghostscript,
  ncurses,
  perl,
  texinfo,
  texliveMedium,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ne";
  version = "3.3.4";

  src = fetchFromGitHub {
    owner = "vigna";
    repo = "ne";
    tag = finalAttrs.version;
    hash = "sha256-n8PERQD9G4jmW4avQjbFofrSapyRoSbQ2k1LzVt0i1o=";
  };

  postPatch = ''
    substituteInPlace makefile --replace-fail "./version.pl" "perl version.pl"
    substituteInPlace src/makefile --replace-fail "-lcurses" "-lncurses"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    texliveMedium
    texinfo
    perl
    ghostscript
  ];

  buildInputs = [ ncurses ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Nice editor";

    longDescription = ''
      ne is a free (GPL'd) text editor based on the POSIX standard that runs
      (we hope) on almost any UN*X machine.  ne is easy to use for the beginner,
      but powerful and fully configurable for the wizard, and most sparing in its
      resource usage.  See the manual for some highlights of ne's features.
    '';

    homepage = "https://ne.di.unimi.it/";
    changelog = "https://github.com/vigna/ne/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ geri1701 ];
    platforms = lib.platforms.unix;
    mainProgram = "ne";
    downloadPage = "https://github.com/vigna/ne";
  };
})
