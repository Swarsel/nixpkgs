{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cmdliner,
  dap,
  fmt,
  gitUpdater,
  iter,
  logs,
  lru,
  lwt_ppx,
  lwt_react,
  menhir,
  menhirLib,
  ocaml,
  path_glob,
  ppx_deriving_yojson,
  ppx_optcomp,
}:

buildDunePackage (finalAttrs: {
  pname = "earlybird";
  version = "1.3.6";

  src = fetchFromGitHub {
    owner = "hackwaly";
    repo = "ocamlearlybird";
    tag = finalAttrs.version;
    hash = "sha256-UtJwb941JEIaE4zUlOWqFX3w0U7gFdYlYpKl+mZ1FNg=";
  };

  nativeBuildInputs = [ menhir ];

  buildInputs = [
    cmdliner
    dap
    fmt
    iter
    logs
    lru
    lwt_ppx
    lwt_react
    menhirLib
    path_glob
    ppx_deriving_yojson
    ppx_optcomp
  ];

  minimalOCamlVersion = "4.12";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "OCaml debug adapter";
    homepage = "https://github.com/hackwaly/ocamlearlybird";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.romildo ];
  };
})
