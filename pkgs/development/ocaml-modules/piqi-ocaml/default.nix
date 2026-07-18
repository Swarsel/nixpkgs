{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  num,
  ocaml,
  piqi,
  stdlib-shims,
}:

stdenv.mkDerivation rec {
  pname = "piqi-ocaml";
  version = "0.7.8";

  src = fetchFromGitHub {
    owner = "alavrik";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-6Luq49sbo+AqLSq57mc6fLhrRx0K6G5LCUIzkGPfqYo=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildInputs = [
    piqi
    stdlib-shims
  ];

  checkInputs = [ num ];

  installPhase = ''
    runHook preInstall
    DESTDIR=$out make install
    runHook postInstall
  '';

  createFindlibDestdir = true;
  name = "ocaml${ocaml.version}-${pname}-${version}";

  meta = {
    description = "Universal schema language and a collection of tools built around it. These are the ocaml bindings";
    homepage = "https://piqi.org";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.maurer ];
    mainProgram = "piqic-ocaml";
  };
}
