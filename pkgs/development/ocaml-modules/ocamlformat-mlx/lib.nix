{
  lib,
  fetchFromGitHub,
  alcotest,
  astring,
  base,
  buildDunePackage,
  camlp-streams,
  csexp,
  dune-build-info,
  either,
  fix,
  fpath,
  menhir,
  menhirLib,
  menhirSdk,
  ocaml-version,
  ocamlformat-rpc-lib,
  ocp-indent,
  odoc,
  result,
  stdio,
  uuseg,
}:
buildDunePackage (finalAttrs: {
  pname = "ocamlformat-mlx-lib";
  version = "0.28.1.2";

  src = fetchFromGitHub {
    owner = "ocaml-mlx";
    repo = "ocamlformat-mlx";
    tag = finalAttrs.version;
    hash = "sha256-IxX8FD7v9evHFTCnTJBtnUMUUTWI34zIifpciuJCuhs=";
  };

  nativeBuildInputs = [
    menhir
  ];

  propagatedBuildInputs = [
    alcotest
    base
    dune-build-info
    either
    fix
    fpath
    menhirLib
    menhirSdk
    ocaml-version
    ocamlformat-rpc-lib
    ocp-indent
    stdio
    uuseg
    csexp
    astring
    result
    camlp-streams
    odoc
  ];

  meta = {
    description = "OCaml .mlx Code Formatter";
    homepage = "https://github.com/ocaml-mlx/ocamlformat-mlx";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      Denommus
    ];
  };
})
