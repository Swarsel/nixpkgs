{
  lib,
  build-system,
  buildPythonPackage,
  lang,
  src,
  version,
}:

buildPythonPackage rec {
  inherit version src build-system;
  pname = "gruut-lang-${lang}";
  doCheck = false;

  prePatch = ''
    cd "${pname}"
  '';

  pyproject = true;
  pythonImportsCheck = [ "gruut_lang_${lang}" ];

  meta = {
    description = "Language files for gruut tokenizer/phonemizer";
    homepage = "https://github.com/rhasspy/gruut";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
