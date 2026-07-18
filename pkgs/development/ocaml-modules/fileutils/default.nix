{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  ounit2,
  seq,
  stdlib-shims,
}:

buildDunePackage (finalAttrs: {
  pname = "fileutils";
  version = "0.6.6";

  src = fetchurl {
    url = "https://github.com/gildor478/ocaml-fileutils/releases/download/v${finalAttrs.version}/fileutils-${finalAttrs.version}.tbz";
    hash = "sha256-eW1XkeK/ezv/IAz1BXp6GHhDnrzXTtDxCIz4Z1bVK+Y=";
  };

  propagatedBuildInputs = [
    seq
    stdlib-shims
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    ounit2
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "OCaml API to manipulate real files (POSIX like) and filenames";
    homepage = "https://github.com/gildor478/ocaml-fileutils";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
