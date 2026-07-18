{
  lib,
  stdenv,
  fetchFromGitHub,
  bitwuzla-cxx,
  bos,
  buildDunePackage,
  cmdliner,
  darwin,
  dolmen_model,
  dolmen_type,
  dune-build-info,
  dune-site,
  fpath,
  hc,
  mdx,
  menhir,
  menhirLib,
  mtime,
  ocaml,
  ounit2,
  ppx_enumerate,
  prelude,
  scfg,
  yojson,
  z3,
  zarith,
  # fix eval on legacy ocaml versions
  ocaml_intrinsics ? null,
}:

buildDunePackage (finalAttrs: {
  pname = "smtml";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "formalsec";
    repo = "smtml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TZMBUnw1AtsVUfLLQJ/gs0CBtnphBiREH99QP3VuAL0=";
  };

  nativeBuildInputs = [
    menhir
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  buildInputs = [
    dune-build-info
    dune-site
  ];

  propagatedBuildInputs = [
    bitwuzla-cxx
    bos
    cmdliner
    dolmen_model
    dolmen_type
    fpath
    hc
    menhirLib
    mtime
    ocaml_intrinsics
    ppx_enumerate
    prelude
    scfg
    yojson
    z3
    zarith
  ];

  doCheck =
    # Checks fail with cmdliner ≥ 2.0
    false
    && !(
      lib.versions.majorMinor ocaml.version == "5.0"
      || lib.versions.majorMinor ocaml.version == "5.4"
      || stdenv.hostPlatform.isDarwin
    );

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    mdx
    ounit2
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "SMT solver frontend for OCaml";
    homepage = "https://formalsec.github.io/smtml/smtml/";
    changelog = "https://github.com/formalsec/smtml/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ethancedwards8
      redianthus
    ];

    downloadPage = "https://github.com/formalsec/smtml";
    teams = with lib.teams; [ ngi ];
  };
})
