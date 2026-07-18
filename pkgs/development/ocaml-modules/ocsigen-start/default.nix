{
  lib,
  stdenv,
  fetchFromGitHub,
  cohttp-lwt-unix,
  eliom,
  findlib,
  ocaml,
  ocsigen-ppx-rpc,
  ocsigen-toolkit,
  pgocaml_ppx,
  resource-pooling,
  safepass,
  yojson,
}:

stdenv.mkDerivation {
  pname = "ocaml${ocaml.version}-ocsigen-start";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "ocsigen-start";
    rev = "b64139e365ab1d244033133629431f7a73e3e054";
    hash = "sha256-N6bPEibcN7WM23hSK4260+hZWo9PSRoSLjemF7m/9Ic=";
  };

  patches = [
    ./templates-dir.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    eliom
  ];

  buildInputs = [ ocsigen-ppx-rpc ];

  propagatedBuildInputs = [
    pgocaml_ppx
    safepass
    ocsigen-toolkit
    yojson
    resource-pooling
    cohttp-lwt-unix
  ];

  preInstall = ''
    mkdir -p $OCAMLFIND_DESTDIR
  '';

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Eliom application skeleton";

    longDescription = ''
      An Eliom application skeleton, ready to use to build your own application with users, (pre)registration, notifications, etc.
    '';

    homepage = "http://ocsigen.org/ocsigen-start";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.gal_bolle ];
  };

}
