{
  lib,
  stdenv,
  fetchFromGitLab,
  camlp4,
  config-file,
  findlib,
  lablgtk,
  ocaml,
  xmlm,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-lablgtk-extras";
  version = "1.6";

  src = fetchFromGitLab {
    owner = "zoggy";
    repo = "lablgtk-extras";
    rev = "release-${version}";
    sha256 = "1bbdp5j18s582mmyd7qiaq1p08g2ag4gl7x65pmzahbhg719hjda";
    domain = "framagit.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    camlp4
  ];

  propagatedBuildInputs = [
    config-file
    lablgtk
    xmlm
  ];

  createFindlibDestdir = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Collection of libraries and modules useful when developing OCaml/LablGtk2 applications";
    homepage = "https://framagit.org/zoggy/lablgtk-extras/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ vbgl ];
    broken = lib.versionOlder ocaml.version "4.02" || lib.versionAtLeast ocaml.version "4.13";
  };
}
