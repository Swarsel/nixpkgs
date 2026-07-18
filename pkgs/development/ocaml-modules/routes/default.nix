{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "routes";
  version = "2.0.0";

  src = fetchurl {
    url = "https://github.com/anuragsoni/routes/releases/download/${finalAttrs.version}/routes-${finalAttrs.version}.tbz";
    hash = "sha256-O2KdaYwrAOUEwTtM14NUgGNxnc8BWAycP1EEuB6w1og=";
  };

  duneVersion = "3";
  minimalOCamlVersion = "4.05";

  meta = {
    description = "Typed routing for OCaml applications";
    homepage = "https://anuragsoni.github.io/routes";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      ulrikstrid
    ];
  };
})
