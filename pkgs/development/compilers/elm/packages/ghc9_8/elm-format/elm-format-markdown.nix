{
  lib,
  base,
  containers,
  fetchgit,
  mkDerivation,
  mtl,
  text,
}:
mkDerivation {
  pname = "elm-format-markdown";
  version = "0.0.0.1";

  src = fetchgit {
    url = "https://github.com/avh4/elm-format";
    rev = "d07fddc8c0eef412dba07be4ab8768d6abcca796";
    sha256 = "13i1wgva6p9zsx1a7sfb3skc0rv187isb920chkhljyh48c12k8l";
    fetchSubmodules = true;
  };

  description = "Markdown parsing for Elm documentation comments";
  doHaddock = false;

  libraryHaskellDepends = [
    base
    containers
    mtl
    text
  ];

  license = lib.licenses.bsd3;
  postUnpack = "sourceRoot+=/elm-format-markdown; echo source root reset to $sourceRoot";
}
