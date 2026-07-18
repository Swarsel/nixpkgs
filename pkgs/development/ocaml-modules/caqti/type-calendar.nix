{
  buildDunePackage,
  calendar,
  caqti,
}:

buildDunePackage {
  inherit (caqti) src version;
  pname = "caqti-type-calendar";

  propagatedBuildInputs = [
    calendar
    caqti
  ];

  meta = caqti.meta // {
    description = "Date and time field types using the calendar library";
  };
}
