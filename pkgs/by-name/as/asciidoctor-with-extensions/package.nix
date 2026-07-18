{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  jre, # Used by asciidoctor-diagram for ditaa and PlantUML
  makeWrapper,
  withJava ? true,
}:

let
  path = lib.makeBinPath (lib.optional withJava jre);
in
bundlerApp rec {
  pname = "asciidoctor";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = lib.optionalString (path != "") (
    lib.concatMapStrings (exe: ''
      wrapProgram $out/bin/${exe} \
        --prefix PATH : ${path}
    '') exes
  );

  exes = [
    "asciidoctor"
    "asciidoctor-epub3"
    "asciidoctor-multipage"
    "asciidoctor-pdf"
    "asciidoctor-reducer"
    "asciidoctor-revealjs"
  ];

  gemdir = ./.;

  passthru = {
    updateScript = bundlerUpdateScript "asciidoctor-with-extensions";
  };

  meta = {
    description = "Faster Asciidoc processor written in Ruby, with many extensions enabled";
    homepage = "https://asciidoctor.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.unix;
  };
}
