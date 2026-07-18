{
  lib,
  fetchurl,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pixel2svg";
  version = "0.3.0";

  src = fetchurl {
    url = "https://static.florian-berger.de/pixel2svg-${finalAttrs.version}.zip";
    hash = "sha256-aqcTTmZKcdRdVd8GGz5cuaQ4gjPapVJNtiiZu22TZgQ=";
  };

  nativeCheckInputs = [ versionCheckHook ];
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pillow
    svgwrite
  ];

  pyproject = true;

  meta = {
    description = "Converts pixel art to SVG - pixel by pixel";
    homepage = "https://florian-berger.de/en/software/pixel2svg/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ annaaurora ];
    mainProgram = "pixel2svg.py";
  };
})
