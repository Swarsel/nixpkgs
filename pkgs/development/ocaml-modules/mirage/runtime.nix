{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  cmdliner,
  ipaddr,
  logs,
  lwt,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-runtime";
  version = "4.10.2";

  src = fetchurl {
    url = "https://github.com/mirage/mirage/releases/download/v${finalAttrs.version}/mirage-${finalAttrs.version}.tbz";
    hash = "sha256:4184cbc7e51b0dcdcf4345c98818c34129ff42879ef091e54849faa57b29d397";
  };

  propagatedBuildInputs = [
    cmdliner
    ipaddr
    logs
    lwt
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Base MirageOS runtime library, part of every MirageOS unikernel";
    homepage = "https://github.com/mirage/mirage";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
