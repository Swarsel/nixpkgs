{
  lib,
  aches,
  buildDunePackage,
  lwt,
  ringo,
}:

buildDunePackage {
  inherit (ringo) src version;
  pname = "aches-lwt";

  propagatedBuildInputs = [
    aches
    lwt
  ];

  meta = {
    description = "Caches (bounded-size stores) for Lwt promises";
    homepage = "https://gitlab.com/nomadic-labs/ringo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
