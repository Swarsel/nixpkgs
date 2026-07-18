{
  lib,
  inkscape,
  inkscape-extensions,
  makeWrapper,
  symlinkJoin,
  inkscapeExtensions ? [ ],
}:

let
  allExtensions = lib.filter (pkg: lib.isDerivation pkg && !pkg.meta.broken or false) (
    lib.attrValues inkscape-extensions
  );
  selectedExtensions = if inkscapeExtensions == null then allExtensions else inkscapeExtensions;
in

symlinkJoin {
  inherit (inkscape) version;
  inherit (inkscape) meta;
  pname = "inkscape-with-extensions";

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm -f $out/bin/inkscape
    makeWrapper "${inkscape}/bin/inkscape" "$out/bin/inkscape" --set INKSCAPE_DATADIR "$out/share"

    ln -s ${inkscape.man} $man
  '';

  paths = [ inkscape ] ++ selectedExtensions;
}
