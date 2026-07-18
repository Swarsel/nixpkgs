{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cohttp,
  cohttp-lwt,
  github-data,
  lwt,
  stringext,
  uri,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "github";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "mirage";
    repo = "ocaml-github";
    rev = finalAttrs.version;
    sha256 = "sha256-nxHXOdZAvFe5/lKNw7tTJmY86xzfdFT+fW+lnKioyPM=";
  };

  propagatedBuildInputs = [
    uri
    cohttp
    lwt
    cohttp-lwt
    github-data
    yojson
    stringext
  ];

  duneVersion = "3";

  meta = {
    description = "GitHub APIv3 OCaml library";
    homepage = "https://github.com/mirage/ocaml-github";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ niols ];
  };
})
