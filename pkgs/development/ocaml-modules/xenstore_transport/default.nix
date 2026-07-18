{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  lwt,
  xenstore,
}:

buildDunePackage rec {
  pname = "xenstore_transport";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "xapi-project";
    repo = "ocaml-xenstore-clients";
    rev = "v${version}";
    sha256 = "sha256-tnz+dZ3EdzDVTGAe4y7OveXuVEUSh1aJxJabHM4zHTI=";
  };

  propagatedBuildInputs = [
    xenstore
    lwt
  ];

  # requires a mounted xenfs and xen server
  doCheck = false;
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Low-level libraries for connecting to a xenstore service on a xen host";
    homepage = "https://github.com/xapi-project/ocaml-xenstore-clients";
    license = lib.licenses.lgpl21Only;
    teams = [ lib.teams.xen ];
  };
}
