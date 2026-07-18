{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  ncurses,
  pcre2,
  quilt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ccze";
  version = "0.2.1-8";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "ccze";
    rev = "debian/${finalAttrs.version}";
    hash = "sha256-sESbs+HTDRX9w7c+LYnzQoemPIxAtqk27IVSTtiAGEk=";
    domain = "salsa.debian.org";
  };

  outputs = [
    "out"
    "man"
    "dev"
    "lib"
  ];

  postPatch = ''
    QUILT_PATCHES=debian/patches quilt push -a
  '';

  nativeBuildInputs = [
    autoconf
    quilt
  ];

  buildInputs = [
    ncurses
    pcre2
  ];

  # provide correct pcre2-config for cross
  env.PCRE_CONFIG = lib.getExe' (lib.getDev pcre2) "pcre2-config";

  preConfigure = ''
    autoheader
    autoconf
  '';

  meta = {
    description = "Fast, modular log colorizer";

    longDescription = ''
      Fast log colorizer written in C, intended to be a drop-in replacement for the Perl colorize tool.
      Includes plugins for a variety of log formats (Apache, Postfix, Procmail, etc.).
    '';

    homepage = "https://salsa.debian.org/debian/ccze";
    changelog = "https://salsa.debian.org/debian/ccze/-/raw/master/debian/changelog?ref_type=heads";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      malyn
      philiptaron
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ccze";
  };
})
