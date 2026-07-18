{
  lib,
  buildDunePackage,
  ringo,
}:

buildDunePackage {
  inherit (ringo) src version;
  pname = "aches";

  propagatedBuildInputs = [
    ringo
  ];

  meta = {
    description = "Caches (bounded-size stores) for in-memory values and for resources";
    homepage = "https://gitlab.com/nomadic-labs/ringo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
