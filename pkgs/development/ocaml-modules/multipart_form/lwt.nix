{
  buildDunePackage,
  lwt,
  multipart_form,
}:

buildDunePackage {
  inherit (multipart_form) version src meta;
  pname = "multipart_form-lwt";

  propagatedBuildInputs = [
    lwt
    multipart_form

  ];
}
