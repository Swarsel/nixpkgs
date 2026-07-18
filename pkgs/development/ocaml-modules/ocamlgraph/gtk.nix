{
  buildDunePackage,
  lablgtk,
  ocamlgraph,
}:

buildDunePackage {
  inherit (ocamlgraph) version src meta;
  pname = "ocamlgraph_gtk";

  propagatedBuildInputs = [
    lablgtk
    ocamlgraph
  ];
}
