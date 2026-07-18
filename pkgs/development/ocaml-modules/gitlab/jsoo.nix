{
  buildDunePackage,
  cohttp,
  cohttp-lwt-jsoo,
  gitlab,
  js_of_ocaml-lwt,
}:

buildDunePackage {
  inherit (gitlab) version src;
  pname = "gitlab-jsoo";

  propagatedBuildInputs = [
    gitlab
    cohttp
    cohttp-lwt-jsoo
    js_of_ocaml-lwt
  ];

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = gitlab.meta // {
    description = "Gitlab APIv4 JavaScript library";
  };
}
