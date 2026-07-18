{
  lib,
  fetchurl,
  buildDunePackage,
  cmdliner,
  cppo,
  ocp-indent,
  re,
}:

buildDunePackage (finalAttrs: {
  pname = "ocp-index";
  version = "1.4.1";

  src = fetchurl {
    url = "https://github.com/OCamlPro/ocp-index/releases/download/${finalAttrs.version}/ocp-index-${finalAttrs.version}.tbz";
    hash = "sha256:59adbd99a9c88106dcf23bc0e3424a00f840fcedee4e4b644eaf0385ada3f911";
  };

  nativeBuildInputs = [ cppo ];

  buildInputs = [
    cmdliner
    re
  ];

  propagatedBuildInputs = [ ocp-indent ];

  meta = {
    description = "Simple and light-weight documentation extractor for OCaml";
    homepage = "https://www.typerex.org/ocp-index.html";
    changelog = "https://github.com/OCamlPro/ocp-index/raw/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
