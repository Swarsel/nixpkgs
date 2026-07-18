{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ounit,
  ppx_deriving,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "lens";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "pdonadeo";
    repo = "ocaml-lens";
    rev = "v${finalAttrs.version}";
    sha256 = "1k23n7pa945fk6nbaq6nlkag5kg97wsw045ghz4gqp8b9i2im3vn";
  };

  buildInputs = [
    ppx_deriving
    ppxlib
  ];

  doCheck = true;
  checkInputs = [ ounit ];
  duneVersion = "3";
  minimalOCamlVersion = "4.10";

  meta = {
    description = "Functional lenses";
    homepage = "https://github.com/pdonadeo/ocaml-lens";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      kazcw
    ];
  };
})
