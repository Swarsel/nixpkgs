{
  buildDunePackage,
  cmdliner,
  cohttp,
  cohttp-lwt-unix,
  fetchpatch,
  github,
  lwt,
  stringext,
}:

buildDunePackage {
  inherit (github) version src;
  pname = "github-unix";

  postPatch = ''
    substituteInPlace unix/dune --replace-fail 'github bytes' 'github'
  '';

  propagatedBuildInputs = [
    github
    cohttp
    cohttp-lwt-unix
    stringext
    cmdliner
    lwt
  ];

  meta = github.meta // {
    description = "GitHub APIv3 Unix library";
  };
}
