{
  buildDunePackage,
  lablgtk,
  zelus,
}:

buildDunePackage {
  inherit (zelus) version src postPatch;
  pname = "zelus-gtk";

  nativeBuildInputs = [
    zelus
  ];

  buildInputs = [
    lablgtk
  ];

  minimalOCamlVersion = "4.10";

  meta = {
    inherit (zelus.meta) homepage license maintainers;
    description = "Zelus GTK library";
  };
}
