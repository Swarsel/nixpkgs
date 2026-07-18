{
  kirigami-addons,
  kquickcharts,
  kxmlgui,
  mkKdeDerivation,
}:
mkKdeDerivation {
  pname = "filelight";

  extraBuildInputs = [
    kirigami-addons
    kquickcharts
    kxmlgui
  ];

  meta.mainProgram = "filelight";
}
