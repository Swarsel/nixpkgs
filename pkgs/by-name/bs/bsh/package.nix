{
  lib,
  fetchurl,
}:

fetchurl (finalAttrs: {
  pname = "bsh";
  version = "2.1.1";
  hash = "sha256-cRksu+Seeiac/LoF3Fy5WcM7myba/NYmbKMoi0YfhqM=";
  name = "${finalAttrs.pname}-${finalAttrs.version}.jar";
  url = "https://github.com/beanshell/beanshell/releases/download/${finalAttrs.version}/bsh-${finalAttrs.version}.jar";

  meta = {
    license = lib.licenses.asl20;
  };
})
