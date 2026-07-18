{
  astring,
  bos,
  buildDunePackage,
  cmdliner,
  emile,
  fmt,
  fpath,
  ipaddr,
  logs,
  mirage-runtime,
  ocaml,
  rresult,
  uri,
}:

buildDunePackage (finalAttrs: {
  inherit (mirage-runtime) version src;
  pname = "mirage";

  outputs = [
    "out"
    "dev"
  ];

  propagatedBuildInputs = [
    astring
    bos
    cmdliner
    emile
    fmt
    fpath
    ipaddr
    logs
    rresult
    uri
  ];

  # Tests need opam-monorepo
  doCheck = false;

  installPhase = ''
    runHook preInstall
    dune install --prefix=$out --libdir=$dev/lib/ocaml/${ocaml.version}/site-lib/ mirage
    runHook postInstall
  '';

  minimalOCamlVersion = "4.13";

  meta = mirage-runtime.meta // {
    description = "MirageOS library operating system";
  };
})
