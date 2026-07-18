{
  lib,
  buildDunePackage,
  dune-configurator,
  ocaml_gettext,
  ounit2,
}:

buildDunePackage {
  inherit (ocaml_gettext) src version;
  pname = "gettext-stub";
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ ocaml_gettext ];
  doCheck = true;
  checkInputs = [ ounit2 ];
  minimalOCamlVersion = "4.14";
  meta = removeAttrs ocaml_gettext.meta [ "mainProgram" ];
}
