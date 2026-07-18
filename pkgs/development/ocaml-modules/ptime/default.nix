{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (topkg) buildPhase installPhase;
  pname = "ocaml${ocaml.version}-ptime";
  version = "1.2.0";

  src = fetchurl {
    url = "https://erratique.ch/software/ptime/releases/ptime-${finalAttrs.version}.tbz";
    hash = "sha256-lhZ0f99JDsNugCTKsn7gHjoK9XfYojImY4+kA03nOrA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    findlib
    ocaml
    ocamlbuild
    topkg
  ];

  buildInputs = [
    topkg
  ];

  meta = {
    description = "POSIX time for OCaml";

    longDescription = ''
      Ptime has platform independent POSIX time support in pure OCaml.
      It provides a type to represent a well-defined range of POSIX timestamps
      with picosecond precision, conversion with date-time values, conversion
      with RFC 3339 timestamps and pretty printing to a human-readable,
      locale-independent representation.

      The additional Ptime_clock library provides access to a system POSIX clock
      and to the system's current time zone offset.

      Ptime is not a calendar library.
    '';

    homepage = "https://erratique.ch/software/ptime";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
    broken = !(lib.versionAtLeast ocaml.version "4.08");
  };
})
