{
  leptonica,
  mkKdeDerivation,
  qtwebengine,
  tesseract5,
  tesseractLanguages ? [ ],
}:
mkKdeDerivation {
  pname = "skanpage";

  extraBuildInputs = [
    qtwebengine
    (tesseract5.override { enableLanguages = tesseractLanguages; })
    leptonica
  ];

  meta.mainProgram = "skanpage";
}
