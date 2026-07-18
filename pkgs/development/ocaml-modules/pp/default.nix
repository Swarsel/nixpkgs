{
  lib,
  fetchurl,
  buildDunePackage,
  ppx_expect,
  version ? "2.0.0",
}:

buildDunePackage (finalAttrs: {
  inherit version;
  pname = "pp";

  src = fetchurl {
    url = "https://github.com/ocaml-dune/pp/releases/download/${finalAttrs.version}/pp-${finalAttrs.version}.tbz";

    hash =
      {
        "1.2.0" = "sha256-pegiVzxVr7Qtsp7FbqzR8qzY9lzy3yh44pHeN0zmkJw=";
        "2.0.0" = "sha256-hlE1FRiwkrSi3vTggXHCdhUvkvtqhKixm2uSnM20RBk=";
      }
      ."${finalAttrs.version}";
  };

  doCheck = true;
  checkInputs = [ ppx_expect ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Alternative pretty printing library to the Format module of the OCaml standard library";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
