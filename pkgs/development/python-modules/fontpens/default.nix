{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fonttools,
  hatch-vcs,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "fontpens";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "robotools";
    repo = "fontpens";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K768vbhacnuSRlmC3QG+7p+y8QiBtvqETvCYOuO1IxM=";
  };

  # can't run normal tests due to circular dependency with fontParts
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ fonttools ];
  pyproject = true;

  pythonImportsCheck = [
    "fontPens"
  ]
  ++ (map (s: "fontPens." + s) [
    "angledMarginPen"
    "digestPointPen"
    "flattenPen"
    "guessSmoothPointPen"
    "marginPen"
    "penTools"
    "printPen"
    "printPointPen"
    "recordingPointPen"
    "thresholdPen"
    "thresholdPointPen"
    "transformPointPen"
  ]);

  meta = {
    description = "Collection of classes implementing the pen protocol for manipulating glyphs";
    homepage = "https://github.com/robotools/fontPens";
    changelog = "https://github.com/robotools/fontPens/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
