{
  lib,
  stdenv,
  fetchurl,
  alcotest,
  astring,
  buildDunePackage,
  camlp-streams,
  cmdliner,
  cppo,
  csexp,
  findlib,
  fmt,
  gitUpdater,
  logs,
  lwt,
  ocaml,
  ocaml-version,
  re,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "mdx";
  version = "2.5.2";

  src = fetchurl {
    url = "https://github.com/realworldocaml/mdx/releases/download/${finalAttrs.version}/mdx-${finalAttrs.version}.tbz";
    hash = "sha256-yEjCxoDGJmLcSgX1WOXGwY7Sqre7ZQjB1JEJ1uqRo88=";
  };

  outputs = [
    "bin"
    "lib"
    "out"
  ];

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    astring
    fmt
    logs
    csexp
    cmdliner
    ocaml-version
    camlp-streams
    re
    result
    findlib
  ];

  env =
    # Fix build with gcc15
    lib.optionalAttrs
      (
        lib.versionAtLeast ocaml.version "4.10" && lib.versionOlder ocaml.version "4.14"
        || lib.versions.majorMinor ocaml.version == "5.0"
      )
      {
        NIX_CFLAGS_COMPILE = "-std=gnu11";
      };

  doCheck = !stdenv.hostPlatform.isDarwin;

  checkInputs = [
    alcotest
    lwt
  ];

  installPhase = ''
    runHook preInstall
    dune install --prefix=$bin --libdir=$lib/lib/ocaml/${ocaml.version}/site-lib mdx
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Executable OCaml code blocks inside markdown files";
    homepage = "https://github.com/realworldocaml/mdx";
    changelog = "https://github.com/realworldocaml/mdx/raw/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.romildo ];
    mainProgram = "ocaml-mdx";
  };
})
