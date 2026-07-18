{
  lib,
  lilypond,
  makeWrapper,
  openlilylib-fonts,
  symlinkJoin,
}:

lib.appendToName "with-fonts" (symlinkJoin {
  inherit (lilypond)
    pname
    outputs
    version
    meta
    ;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for p in $out/bin/*; do
      wrapProgram "$p" --set LILYPOND_DATADIR "$out/share/lilypond/${lilypond.version}"
    done

    ln -s ${lilypond.man} $man
  '';

  paths = [
    lilypond
  ]
  # relevant for lilypond-unstable-with-fonts
  ++ (openlilylib-fonts.override { inherit lilypond; }).all;
})
