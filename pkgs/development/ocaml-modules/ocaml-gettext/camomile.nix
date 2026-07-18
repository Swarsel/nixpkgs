{
  lib,
  buildDunePackage,
  camomile,
  ocaml_gettext,
  ounit2,
}:

buildDunePackage {
  inherit (ocaml_gettext) src version;
  pname = "gettext-camomile";

  propagatedBuildInputs = [
    camomile
    ocaml_gettext
  ];

  doCheck = true;
  checkInputs = [ ounit2 ];

  meta = (removeAttrs ocaml_gettext.meta [ "mainProgram" ]) // {
    description = "Internationalization library using camomile (i18n)";
  };

}
