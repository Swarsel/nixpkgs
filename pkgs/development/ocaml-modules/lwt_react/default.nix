{
  fetchFromGitHub,
  buildDunePackage,
  cppo,
  lwt,
  react,
}:

buildDunePackage {
  pname = "lwt_react";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "lwt";
    tag = "5.6.0";
    hash = "sha256-DLQupCkZ14kOuSQatbb7j07I+jvvDCKpdlaR3rijT4s=";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    lwt
    react
  ];

  meta = {
    inherit (lwt.meta) homepage license maintainers;
    description = "Helpers for using React with Lwt";
  };
}
