{
  buildDunePackage,
  cohttp,
  cohttp-lwt-jsoo,
  github,
  js_of_ocaml-lwt,
}:

buildDunePackage {
  inherit (github) version src;
  pname = "github-jsoo";

  propagatedBuildInputs = [
    github
    cohttp
    cohttp-lwt-jsoo
    js_of_ocaml-lwt
  ];

  duneVersion = "3";

  meta = github.meta // {
    description = "GitHub APIv3 JavaScript library";
  };
}
