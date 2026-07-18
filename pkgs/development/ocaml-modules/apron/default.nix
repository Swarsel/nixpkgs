{
  lib,
  stdenv,
  fetchFromGitHub,
  camlidl,
  findlib,
  flint,
  gmp,
  mlgmpidl,
  mpfr,
  ocaml,
  perl,
  ppl,
  pplite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocaml${ocaml.version}-apron";
  version = "0.9.15";

  src = fetchFromGitHub {
    owner = "antoinemine";
    repo = "apron";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gHLCurydxX1pS66DTAWUJGl9Yqu9RWRjkZh6lXzM7YY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    ocaml
    findlib
    perl
  ];

  buildInputs = [
    gmp
    mpfr
    ppl
    camlidl
    flint
    pplite
  ];

  propagatedBuildInputs = [ mlgmpidl ];

  postInstall = ''
    mkdir -p $dev/lib
    mv $out/lib/ocaml $dev/lib/
  '';

  configurePhase = ''
    runHook preConfigure
    ./configure -prefix $out ${lib.optionalString stdenv.hostPlatform.isDarwin "--no-strip"}
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs
    runHook postConfigure
  '';

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Numerical abstract domain library";
    homepage = "http://apron.cri.ensmp.fr/library/";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
