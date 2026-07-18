{
  lib,
  buildDunePackage,
  js_of_ocaml,
  js_of_ocaml-ppx,
  lwt,
  lwt_log,
  loggerSupport ? !lib.versionAtLeast lwt.version "6.0.0",
}:

buildDunePackage {
  inherit (js_of_ocaml) version src meta;
  pname = "js_of_ocaml-lwt";
  buildInputs = [ js_of_ocaml-ppx ];

  propagatedBuildInputs = [
    js_of_ocaml
    lwt
  ]
  ++ lib.optional loggerSupport lwt_log;
}
