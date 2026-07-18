{
  lib,
  fetchurl,
  buildDunePackage,
  dune-configurator,
}:

buildDunePackage (finalAttrs: {
  pname = "miou";
  version = "0.5.5";

  src = fetchurl {
    url = "https://github.com/robur-coop/miou/releases/download/v${finalAttrs.version}/miou-${finalAttrs.version}.tbz";
    hash = "sha256-YJZ/nlqpxW77mhcamtCMx5d6/f9MVVBv1QCOz55EyuA=";
  };

  buildInputs = [ dune-configurator ];
  minimalOCamlVersion = "5.0.0";

  meta = {
    description = "Composable concurrency primitives for OCaml";
    homepage = "https://git.robur.coop/robur/miou";
    changelog = "https://git.robur.coop/robur/miou/src/tag/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
