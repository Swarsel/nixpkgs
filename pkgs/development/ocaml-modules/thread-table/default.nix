{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  mdx,
}:

buildDunePackage rec {
  pname = "thread-table";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/${pname}/releases/download/${version}/${pname}-${version}.tbz";
    sha256 = "pIzYhGNZfflELEuqaczAYJHKd7px5DjTYJ+64PO4Hd0=";
  };

  doCheck = true;

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    alcotest
    mdx
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Lock-free thread-safe integer keyed hash table";
    homepage = "https://github.com/ocaml-multicore/ocaml-${pname}";
    changelog = "https://github.com/ocaml-multicore/ocaml-${pname}/raw/${version}/CHANGES.md";
    license = with lib.licenses; [ isc ];
    maintainers = with lib.maintainers; [ toastal ];
  };
}
