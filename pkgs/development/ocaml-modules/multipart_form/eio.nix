{
  angstrom,
  bigstringaf,
  buildDunePackage,
  eio,
  ke,
  multipart_form,
}:

buildDunePackage {
  inherit (multipart_form) version src meta;
  pname = "multipart_form-eio";

  propagatedBuildInputs = [
    angstrom
    bigstringaf
    eio
    ke
    multipart_form
  ];
}
