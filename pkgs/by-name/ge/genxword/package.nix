{
  lib,
  fetchFromGitHub,
  gettext,
  gobject-introspection,
  gtksourceview3,
  pango,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "genxword";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "riverrun";
    repo = "genxword";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vzzkXfMnkeTFQmTNAfCIKqVVNm1I6GSfRV1lwGmLj6Y=";
  };

  nativeBuildInputs = [
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    pango
    gtksourceview3
  ];

  # there are no tests
  doCheck = false;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    pycairo
    pygobject3
  ];

  # to prevent double wrapping
  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Crossword generator";
    homepage = "https://github.com/riverrun/genxword";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "genxword";
  };
})
