{
  lib,
  fetchurl,
  buildDunePackage,
  logs,
  ppx_repr,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_irmin";
  version = "3.11.0";

  src = fetchurl {
    url = "https://github.com/mirage/irmin/releases/download/${finalAttrs.version}/irmin-${finalAttrs.version}.tbz";
    hash = "sha256-CZlvvMLEPhF6m9jpAoxjXoHMyyZNXgLUJauLBrus29s=";
  };

  propagatedBuildInputs = [
    ppx_repr
    ppxlib
    logs
  ];

  minimalOCamlVersion = "4.10";

  meta = {
    description = "PPX deriver for Irmin generics";
    homepage = "https://irmin.org/";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      vbgl
      sternenseemann
    ];
  };
})
