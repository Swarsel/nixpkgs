{
  buildNpmPackage,
  open5gs,
}:

buildNpmPackage (finalAttrs: {
  inherit (open5gs) src version meta;
  pname = "${open5gs.pname}-webui";
  npmDepsHash = "sha256-Epz+pCbgejkj7vcdwbPC2RfAkp2HRqGV0urXiiBrjZQ=";
  sourceRoot = "${finalAttrs.src.name}/webui";
})
