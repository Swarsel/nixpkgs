{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cppo,
  dune-configurator,
  libev,
  ocplib-endian,
  ppxlib,
  version ? if lib.versionAtLeast ppxlib.version "0.36" then "6.1.2" else "5.9.1",
}:

buildDunePackage {
  inherit version;
  pname = "lwt";

  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "lwt";
    tag = version;

    hash =
      {
        "5.9.1" = "sha256-oPYLFugMTI3a+hmnwgUcoMgn5l88NP1Roq0agLhH/vI=";
        "5.9.2" = "sha256-pzowRN1wwaF2iMfMPE7RCtA2XjlaXC3xD0yznriVfu8=";
        "6.1.2" = "sha256-9Uxo1ekB3VcvdR4FCVdVWzvPHuVwflYIdD/fWvg0/kc=";
      }
      ."${version}";
  };

  nativeBuildInputs = [ cppo ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    libev
    ocplib-endian
  ];

  meta = {
    description = "Cooperative threads library for OCaml";
    homepage = "https://ocsigen.org/lwt/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
