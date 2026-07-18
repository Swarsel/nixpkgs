{
  lib,
  fetchFromGitHub,
  libsForQt5,
  python3Packages,
  zlib,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "manuskript";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "olivierkes";
    repo = "manuskript";
    tag = finalAttrs.version;
    hash = "sha256-jOhbN6lMx04q60S0VOABmSNE/x9Er9exFYvWJe2INlE=";
  };

  nativeBuildInputs = [ libsForQt5.wrapQtAppsHook ];

  propagatedBuildInputs = [
    python3Packages.pyqt5
    python3Packages.lxml
    zlib
  ];

  buildPhase = "";
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/manuskript
    cp -av  bin/ i18n/ libs/ manuskript/ resources/ icons/ $out
    cp -r sample-projects/ $out/share/manuskript
  '';

  postFixup = ''
    wrapQtApp $out/bin/manuskript
  '';

  patchPhase = ''
    substituteInPlace manuskript/ui/welcome.py \
      --replace sample-projects $out/share/manuskript/sample-projects
  '';

  pyproject = false;

  meta = {
    description = "Open-source tool for writers";

    longDescription = ''
      Manuskript is a tool for those writer who like to organize and
      plan everything before writing.  The snowflake method can help you
      grow your idea into a book, by leading you step by step and asking
      you questions to go deeper. While writing, keep track of notes
      about every characters, plot, event, place in your story.

      Develop complex characters and keep track of all useful infos.
      Create intricate plots, linked to your characters, and use them to
      outline your story. Organize your ideas about the world your
      characters live in.
    '';

    homepage = "https://www.theologeek.ch/manuskript";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ strawbee ];
    platforms = lib.platforms.unix;
    mainProgram = "manuskript";
  };
})
