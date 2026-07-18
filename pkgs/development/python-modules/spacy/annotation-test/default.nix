{
  lib,
  stdenv,
  pytest,
  spacy-models,
}:

stdenv.mkDerivation {
  src = lib.fileset.toSource {
    fileset = lib.fileset.unions [
      ./annotate.py
    ];

    root = ./.;
  };

  nativeCheckInputs = [
    pytest
    spacy-models.en_core_web_sm
  ];

  checkPhase = ''
    pytest annotate.py
  '';

  installPhase = ''
    touch $out
  '';

  dontBuild = true;
  dontConfigure = true;
  name = "spacy-annotation-test";
  meta.timeout = 60;
}
