{
  lib,
  stdenv,
  fetchFromGitHub,
  bash-completion,
  bison,
  callPackage,
  cmake,
  doxygen,
  fetchpatch,
  flex,
  graphviz,
  libffi,
  makeWrapper,
  mcpp,
  ncurses,
  perl,
  python3,
  sqlite,
  zlib,
}:

let
  toolsPath = lib.makeBinPath [
    mcpp
    python3
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "souffle";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "souffle-lang";
    repo = "souffle";
    rev = finalAttrs.version;
    sha256 = "sha256-Umfeb1pGAeK5K3QDRD/labC6IJLsPPJ73ycsAV4yPNM=";
  };

  outputs = [ "out" ];

  patches = [
    ./threads.patch
    ./includes.patch
    (fetchpatch {
      hash = "sha256-L9SK3Dh2cRwxKfEckUSiGGTDsWIZ5B8hoYYcslJpZl4=";
      name = "replace-copy-assignment.patch";
      url = "https://github.com/souffle-lang/souffle/commit/73ebe789ec21772a0c5558639606354bfc3bcbd1.patch";
    })
  ];

  nativeBuildInputs = [
    bison
    cmake
    flex
    mcpp
    doxygen
    graphviz
    makeWrapper
    perl
  ];

  buildInputs = [
    bash-completion
    ncurses
    zlib
    sqlite
    libffi
    python3
  ];

  # these propagated inputs are needed for the compiled Souffle mode to work,
  # since generated compiler code uses them. TODO: maybe write a g++ wrapper
  # that adds these so we can keep the propagated inputs clean?
  propagatedBuildInputs = [
    ncurses
    zlib
    sqlite
    libffi
  ];

  cmakeFlags = [ "-DSOUFFLE_GIT=OFF" ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-but-set-variable";
  };

  postInstall = ''
    wrapProgram "$out/bin/souffle" --prefix PATH : "${toolsPath}"
  '';

  postFixup = ''
    substituteInPlace "$out/bin/souffle-compile.py" \
        --replace-fail "-IPLACEHOLDER_FOR_INCLUDES_THAT_ARE_SET_BY_NIXPKGS" \
                  "-I${lib.getDev ncurses}/include -I${lib.getDev zlib}/include -I${lib.getDev sqlite}/include -I${lib.getDev libffi}/include -I$out/include"
  '';

  hardeningDisable = lib.optionals stdenv.hostPlatform.isDarwin [ "strictoverflow" ];
  passthru.tests = callPackage ./tests.nix { };

  meta = {
    description = "Translator of declarative Datalog programs into the C++ language";
    homepage = "https://souffle-lang.github.io/";
    license = lib.licenses.upl;

    maintainers = with lib.maintainers; [
      thoughtpolice
      wchresta
      markusscherer
    ];

    platforms = lib.platforms.unix;
  };
})
