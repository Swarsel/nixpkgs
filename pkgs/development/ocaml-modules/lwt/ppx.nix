{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  lwt,
  ppxlib,
}:

buildDunePackage {
  inherit (lwt) version src;
  pname = "lwt_ppx";

  propagatedBuildInputs = [
    lwt
    ppxlib
  ];

  meta = {
    inherit (lwt.meta) license homepage maintainers;
    description = "Ppx syntax extension for Lwt";
  };
}
