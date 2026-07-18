{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "bitv";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "backtracking";
    repo = "bitv";
    tag = finalAttrs.version;
    hash = "sha256-jlpVMqYOiKxoU6wuVeYlOC5wRtF4aakljKpop6dfu8w=";
  };

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Bit vector library for OCaml";
    homepage = "https://github.com/backtracking/bitv";
    changelog = "https://github.com/backtracking/bitv/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
