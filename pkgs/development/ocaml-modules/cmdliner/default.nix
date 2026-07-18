{
  lib,
  stdenv,
  fetchurl,
  ocaml,
  version ? "2.1.1",
}:

stdenv.mkDerivation {
  inherit version;
  pname = "cmdliner";

  src = fetchurl {
    url = "https://erratique.ch/software/cmdliner/releases/cmdliner-${version}.tbz";

    hash =
      {
        "1.0.4" = "sha256-XCqT1Er4o4mWosD4D715cP5HUfEEvkcMr6BpNT/ABMA=";
        "1.3.0" = "sha256-joGA9XO0QPanqMII2rLK5KgjhP7HMtInhNG7bmQWjLs=";
        "2.1.1" = "sha256-Bbk40d709UxHgXjxmCgig0UQQx7ZjyrGfLTZCqEg1rY=";
      }
      ."${version}";
  };

  nativeBuildInputs = [ ocaml ];
  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mv $out/lib/ocaml/${ocaml.version}/site-lib/cmdliner/{opam,cmdliner.opam}
  '';

  installFlags = [
    "LIBDIR=$(out)/lib/ocaml/${ocaml.version}/site-lib/cmdliner"
    "DOCDIR=$(out)/share/doc/cmdliner"
  ];

  installTargets = "install install-doc";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml module for the declarative definition of command line interfaces";
    homepage = "https://erratique.ch/software/cmdliner";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
