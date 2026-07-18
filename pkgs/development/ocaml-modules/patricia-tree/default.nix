{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  findlib,
  mdx,
  ocaml,
  ppx_inline_test,
  qcheck-core,
}:

buildDunePackage (finalAttrs: {
  pname = "patricia-tree";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "codex-semantics-library";
    repo = "patricia-tree";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lpmU0KhsyIHxPBiw38ssA7XFEMsRvOT03MByoJG88Xs=";
  };

  # Fix build with gcc15
  env = lib.optionalAttrs (lib.versions.majorMinor ocaml.version == "5.0") {
    NIX_CFLAGS_COMPILE = "-std=gnu11";
  };

  doCheck = true;

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    mdx
    ppx_inline_test
    qcheck-core
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "Patricia Tree data structure in OCaml";
    homepage = "https://codex.top/api/patricia-tree/";
    changelog = "https://github.com/codex-semantics-library/patricia-tree/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://github.com/codex-semantics-library/patricia-tree";
  };
})
