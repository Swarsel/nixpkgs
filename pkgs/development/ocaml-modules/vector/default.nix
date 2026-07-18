{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "vector";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/backtracking/vector/releases/download/${finalAttrs.version}/vector-${finalAttrs.version}.tbz";
    hash = "sha256-8hLR1pPON96w2iVQqrjVUK1epFfFdX3AL4yopm6+ZkE=";
  };

  doCheck = true;

  meta = {
    description = "Resizable arrays for OCaml";
    homepage = "https://github.com/backtracking/vector";
    license = lib.licenses.lgpl2Only;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
