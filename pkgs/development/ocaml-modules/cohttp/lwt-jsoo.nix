{
  buildDunePackage,
  cohttp,
  cohttp-lwt,
  js_of_ocaml,
  js_of_ocaml-lwt,
  js_of_ocaml-ppx,
  logs,
  lwt,
  lwt_ppx,
  nodejs,
}:

buildDunePackage {
  inherit (cohttp-lwt) version src;
  pname = "cohttp-lwt-jsoo";

  propagatedBuildInputs = [
    cohttp
    cohttp-lwt
    logs
    lwt
    js_of_ocaml
    js_of_ocaml-ppx
    js_of_ocaml-lwt
  ];

  doCheck = true;

  checkInputs = [
    nodejs
    lwt_ppx
  ];

  meta = cohttp-lwt.meta // {
    description = "CoHTTP implementation for the Js_of_ocaml JavaScript compiler";
  };
}
