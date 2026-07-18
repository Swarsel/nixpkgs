{
  lib,
  fetchurl,
  buildDunePackage,
  cmdliner,
  findlib,
  menhir,
  menhirLib,
  ocaml,
  ppxlib,
  sedlex,
  yojson,
  version ?
    if lib.versionAtLeast ocaml.version "4.13" then
      "6.4.1"
    else if lib.versionAtLeast ocaml.version "4.11" then
      "6.0.1"
    else
      "5.8.2",
}:

buildDunePackage {
  inherit version;
  pname = "js_of_ocaml-compiler";

  src = fetchurl {
    url = "https://github.com/ocsigen/js_of_ocaml/releases/download/${version}/js_of_ocaml-${version}.tbz";

    hash =
      {
        "5.8.2" = "sha256-ciAZS9L5sU2VgVOlogZ1A1nXtJ3hL+iNdFDThc7L8Eo=";
        "5.9.1" = "sha256-aMlcYIcdjpyaVMgvNeLtUEE7y0QPIg0LNRayoe4ccwc=";
        "6.0.1" = "sha256-gT2+4rYuFUEEnqI6IOQFzyROJ+v6mFl4XPpT4obSxhQ=";
        "6.1.1" = "sha256-0x2kGq5hwCqqi01QTk6TcFIz0wPNgaB7tKxe7bA9YBQ=";
        "6.2.0" = "sha256-fMZBd40bFyo1KogzPuDoxiE2WgrPzZuH44v9243Spdo=";
        "6.3.2" = "sha256-qTr8llTsNGRwH7zg3M86i+uVCKyxLGBFd2vyzxBsq8A=";
        "6.4.1" = "sha256-5Zu//K76ujGRYgVWUUt/U7sySeP4gaBw1yckI03/2Bk=";
      }
      ."${version}";
  };

  nativeBuildInputs = [ menhir ];

  buildInputs = [
    cmdliner
    ppxlib
  ];

  propagatedBuildInputs = [
    menhirLib
    yojson
    findlib
    sedlex
  ];

  meta = {
    description = "Compiler from OCaml bytecode to Javascript";
    homepage = "https://ocsigen.org/js_of_ocaml/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "js_of_ocaml";

    broken =
      (ocaml.version == "4.14.3" || ocaml.version == "4.14.4") && !lib.versionAtLeast version "6.0.0";
  };
}
