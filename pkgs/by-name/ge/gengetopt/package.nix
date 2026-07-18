{
  lib,
  stdenv,
  fetchurl,
  help2man,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gengetopt";
  version = "2.23";

  src = fetchurl {
    url = "mirror://gnu/gengetopt/gengetopt-${finalAttrs.version}.tar.xz";
    sha256 = "1b44fn0apsgawyqa4alx2qj5hls334mhbszxsy6rfr0q074swhdr";
  };

  #Fix, see #28255
  postPatch = ''
    substituteInPlace configure --replace \
      'set -o posix' \
      'set +o posix'
  '';

  nativeBuildInputs = [
    texinfo
    help2man
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    CXXFLAGS = "-std=c++14";
  };

  doCheck = true;

  # attempts to open non-existent file
  preCheck = ''
    rm tests/test_conf_parser_save.sh
  '';

  # test suite is not thread safe
  enableParallelBuilding = false;

  meta = {
    description = "Command-line option parser generator";

    longDescription = ''
      GNU Gengetopt program generates a C function that uses getopt_long
      function to parse the command line options, to validate them and
      fills a struct
    '';

    homepage = "https://www.gnu.org/software/gengetopt/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "gengetopt";
  };
})
