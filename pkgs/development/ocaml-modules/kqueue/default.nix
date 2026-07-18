{
  lib,
  fetchurl,
  buildDunePackage,
  dune-configurator,
  ppx_expect,
  ppx_optcomp,
}:

buildDunePackage (finalAttrs: {
  pname = "kqueue";
  version = "0.4.0";

  src = fetchurl {
    url = "https://github.com/anuragsoni/kqueue-ml/releases/download/${finalAttrs.version}/kqueue-${finalAttrs.version}.tbz";
    hash = "sha256-fJHhmAp0EFzR9JH93a+EHy1auwSBKZV/XcBQLCedJLc=";
  };

  buildInputs = [
    dune-configurator
    ppx_optcomp
  ];

  doCheck = true;

  checkInputs = [
    ppx_expect
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "OCaml bindings for kqueue event notification interface";
    homepage = "https://github.com/anuragsoni/kqueue-ml";
    changelog = "https://github.com/anuragsoni/kqueue-ml/blob/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sixstring982 ];
  };
})
