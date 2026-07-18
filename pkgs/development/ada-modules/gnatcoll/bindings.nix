{
  lib,
  stdenv,
  fetchFromGitHub,
  component,
  # component dependencies
  gmp,
  gnat,
  gnatcoll-core,
  gprbuild,
  libiconv,
  ncurses,
  python3,
  readline,
  xz,
  zlib,
}:

let
  # omit python (2.7), no need to introduce a
  # dependency on an EOL package for no reason
  libsFor = {
    cpp = [ ];
    gmp = [ gmp ];
    iconv = [ libiconv ];
    lzma = [ xz ];

    python3 = [
      python3
      ncurses
    ];

    readline = [ readline ];
    syslog = [ ];
    zlib = [ zlib ];
  };
in

stdenv.mkDerivation rec {
  pname = "gnatcoll-${component}";
  version = "25.0.0";

  src = fetchFromGitHub {
    owner = "AdaCore";
    repo = "gnatcoll-bindings";
    rev = "v${version}";
    sha256 = "0ayc7zvv8w90v0xzhrjk2x88zrsk62xxcm27ya9crlp6affn5idk";
  };

  nativeBuildInputs = [
    gprbuild
    gnat
    python3
  ];

  # propagate since gprbuild needs to find referenced .gpr files
  # and all dependency C libraries when statically linking a
  # downstream executable.
  propagatedBuildInputs = [
    gnatcoll-core
  ]
  ++ libsFor."${component}" or [ ];

  # explicit flag for GPL acceptance because upstream
  # allows a gcc runtime exception for all bindings
  # except for readline (since it is GPL w/o exceptions)
  buildFlags = lib.optionals (component == "readline") [
    "--accept-gpl"
  ];

  buildPhase = ''
    runHook preBuild
    ${python3.interpreter} ${component}/setup.py build --prefix $out $buildFlags
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ${python3.interpreter} ${component}/setup.py install --prefix $out
    runHook postInstall
  '';

  meta = {
    description = "GNAT Components Collection - Bindings to C libraries";
    homepage = "https://github.com/AdaCore/gnatcoll-bindings";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.all;
  };
}
