{
  hunspell,
  mkKdeDerivation,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "konqueror";
  extraBuildInputs = [ qtwebengine ];

  extraCmakeFlags = [
    "-DWebEngineDictConverter_EXECUTABLE=${qtwebengine}/libexec/qwebengine_convert_dict"
  ];

  extraNativeBuildInputs = [ hunspell ];
}
