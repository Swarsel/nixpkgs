{
  buildDunePackage,
  miou,
  multipart_form,
}:

buildDunePackage {
  inherit (multipart_form) version src meta;
  pname = "multipart_form-miou";

  propagatedBuildInputs = [
    miou
    multipart_form
  ];
}
