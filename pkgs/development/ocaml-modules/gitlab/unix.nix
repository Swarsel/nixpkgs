{
  alcotest,
  buildDunePackage,
  cmdliner,
  cohttp,
  cohttp-lwt-unix,
  gitlab,
  lwt,
  stringext,
  tls,
}:

buildDunePackage {
  inherit (gitlab) version src;
  pname = "gitlab-unix";

  postPatch = ''
    substituteInPlace unix/dune --replace-fail "gitlab bytes" "gitlab"
  '';

  buildInputs = [
    cohttp
    tls
    stringext
  ];

  propagatedBuildInputs = [
    gitlab
    cmdliner
    cohttp-lwt-unix
    lwt
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.08";

  meta = gitlab.meta // {
    description = "Gitlab APIv4 Unix library";
  };
}
