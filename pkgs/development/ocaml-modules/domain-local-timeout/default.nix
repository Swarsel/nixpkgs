{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  domain-local-await,
  mdx,
  mtime,
  ocaml,
  psq,
  thread-table,
}:

buildDunePackage (finalAttrs: {
  pname = "domain-local-timeout";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/domain-local-timeout/releases/download/${finalAttrs.version}/domain-local-timeout-${finalAttrs.version}.tbz";
    hash = "sha256-6sCqUkOjN8E+7OLUwVQntkv0vrQDkGDV8KNqDhVm0d8=";
  };

  propagatedBuildInputs = [
    mtime
    psq
    thread-table
  ];

  doCheck = lib.versionAtLeast ocaml.version "5.1";
  nativeCheckInputs = [ mdx.bin ];

  checkInputs = [
    alcotest
    domain-local-await
    mdx
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "Scheduler independent timeout mechanism";
    homepage = "https://github.com/ocaml-multicore/domain-local-timeout";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
