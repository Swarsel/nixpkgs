{
  lib,
  fetchFromGitHub,
  alcobar,
  buildDunePackage,
  dune-build-info,
  lambdasoup,
  logs,
  mdx,
  memtrace,
  psq,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "cascade";
  version = "0-unstable-2026-06-26";

  src = fetchFromGitHub {
    owner = "samoht";
    repo = "cascade";
    rev = "434c07be7ec1a63213a234946d57937e4d080feb";
    hash = "sha256-6g8UKsXdR0PxihrOiMVC36q7+bomMByPDbmuISL7h4U=";
  };

  buildInputs = [
    lambdasoup
    memtrace
  ];

  propagatedBuildInputs = [
    dune-build-info
    logs
    psq
    uutf
  ];

  doCheck = true;
  nativeCheckInputs = [ mdx.bin ];

  checkInputs = [
    (mdx.override { inherit logs; })
    alcobar
  ];

  __structuredAttrs = true;
  minimalOCamlVersion = "5.2";

  meta = {
    description = "CSS generation and manipulation library for OCaml";
    homepage = "https://github.com/samoht/cascade";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vog ];
  };
})
