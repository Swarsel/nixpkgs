{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  gitUpdater,
  mdx,
  ocaml,
}:

buildDunePackage (finalAttrs: {
  pname = "printbox";
  version = "0.12";

  src = fetchFromGitHub {
    owner = "c-cube";
    repo = "printbox";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-PQbr2sjASoWz0OHAMV6buAJERpnUJxVpLAigIVnADIc=";
  };

  # mdx is not available for OCaml < 4.08
  doCheck = lib.versionAtLeast ocaml.version "4.08";
  nativeCheckInputs = [ mdx.bin ];
  minimalOCamlVersion = "4.04";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Allows to print nested boxes, lists, arrays, tables in several formats";
    homepage = "https://github.com/c-cube/printbox/";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.romildo ];
  };
})
