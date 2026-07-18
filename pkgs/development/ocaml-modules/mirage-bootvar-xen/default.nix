{
  lib,
  fetchurl,
  buildDunePackage,
  lwt,
  mirage-xen,
  parse-argv,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-bootvar-xen";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-bootvar-xen/releases/download/v${finalAttrs.version}/mirage-bootvar-xen-v${finalAttrs.version}.tbz";
    hash = "sha256:0nk80giq9ng3svbnm68fjby2f1dnarddm3lk7mw7w59av71q0rcv";
  };

  propagatedBuildInputs = [
    mirage-xen
    lwt
    parse-argv
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Handle boot-time arguments for Xen platform";
    homepage = "https://github.com/mirage/mirage-bootvar-xen";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
