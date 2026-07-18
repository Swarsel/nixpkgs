{
  lib,
  fetchFromGitLab,
  apron,
  arg-complete,
  buildDunePackage,
  camlidl,
  clang,
  flint,
  libclang,
  libllvm,
  menhir,
  mpfr,
  ocaml,
  pplite,
  yojson,
  zarith,
}:

buildDunePackage (finalAttrs: {
  pname = "mopsa";
  version = "1.1";

  src = fetchFromGitLab {
    owner = "mopsa";
    repo = "mopsa-analyzer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lO5dtGAl1dq8oJco/hPXrAbN05rKc62Zrci/8CLrQ0c=";
  };

  outputs = [
    "bin"
    "out"
  ];

  postPatch = ''
    patchShebangs bin
  '';

  nativeBuildInputs = [
    clang
    libllvm
    menhir
  ];

  buildInputs = [
    arg-complete
    camlidl
    mpfr
  ];

  propagatedBuildInputs = [
    apron
    flint
    libclang
    pplite
    yojson
    zarith
  ];

  buildPhase = ''
    runHook preBuild
    dune build --profile release -p mopsa
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    dune install --profile release --prefix=$bin --libdir=$out/lib/ocaml/${ocaml.version}/site-lib
    runHook postInstall
  '';

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Modular and Open Platform for Static Analysis using Abstract Interpretation";
    homepage = "https://mopsa.lip6.fr/";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
