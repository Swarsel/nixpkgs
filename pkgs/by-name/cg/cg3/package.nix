{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cg3,
  cmake,
  dieHook,
  icu,
  pkg-config,
  runCommand,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cg3";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "GrammarSoft";
    repo = "cg3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R3ePghkr4m6FmiHfhPVdLRAJaipIBhGLOX0Hz1nNPv4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    icu
    boost
    sqlite
  ];

  doCheck = true;

  postFixup = ''
    substituteInPlace "$out"/lib/pkgconfig/cg3.pc \
      --replace-fail '=''${prefix}//' '=/'
  '';

  passthru.tests.minimal =
    runCommand "cg3-test"
      {
        buildInputs = [
          cg3
          dieHook
        ];
      }
      ''
        echo 'DELIMITERS = "."; ADD (tag) (*);' >grammar.cg3
        printf '"<a>"\n\t"a" tag\n\n' >want.txt
        printf '"<a>"\n\t"a"\n\n' | vislcg3 -g grammar.cg3 >got.txt
        diff -s want.txt got.txt || die "Grammar application did not produce expected parse"
        touch $out
      '';

  # TODO, consider optionals:
  # - Enable tcmalloc unless darwin?
  # - Enable python bindings?
  meta = {
    description = "Constraint Grammar interpreter, compiler and applicator vislcg3";
    homepage = "https://github.com/GrammarSoft/cg3";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ unhammer ];
    platforms = lib.platforms.all;
  };
})
