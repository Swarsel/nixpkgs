{
  kholidays,
  mkKdeDerivation,
  qtcharts,
  qtsvg,
}:
mkKdeDerivation {
  pname = "kweather";

  extraBuildInputs = [
    qtsvg
    qtcharts
    kholidays
  ];

  meta.mainProgram = "kweather";
}
