{
  lib,
  fetchurl,
  buildDunePackage,
  cstruct,
  dune-configurator,
  fmt,
  mdx,
  ocaml,
  optint,
  version ? if lib.versionAtLeast ocaml.version "5.1" then "2.7.0" else "0.9",
}:

let
  param =
    {
      "0.9" = {
        hash = "sha256-eXWIxfL9UsKKf4sanBjKfr6Od4fPDctVnkU+wjIXW0M=";
        minimalOCamlVersion = "4.12";
      };

      "2.7.0" = {
        hash = "sha256-mePi6/TXtxgtLYLyHRAdnRcgeldCVgUaPY+MZXSzC6U=";
        minimalOCamlVersion = "5.1.0";
      };
    }
    .${version};
in
buildDunePackage rec {
  inherit version;
  inherit (param) minimalOCamlVersion;
  pname = "uring";

  src = fetchurl {
    inherit (param) hash;
    url = "https://github.com/ocaml-multicore/ocaml-${pname}/releases/download/v${version}/${pname}-${version}.tbz";
  };

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    cstruct
    fmt
    optint
  ];

  # Tests use io_uring, which is blocked by Lix's sandbox because it's
  # opaque to seccomp.
  doCheck = false;

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    mdx
  ];

  dontStrip = true;

  meta = {
    description = "Bindings to io_uring for OCaml";
    homepage = "https://github.com/ocaml-multicore/ocaml-${pname}";
    changelog = "https://github.com/ocaml-multicore/ocaml-${pname}/raw/v${version}/CHANGES.md";

    license = with lib.licenses; [
      isc
      mit
    ];

    maintainers = with lib.maintainers; [ toastal ];
    platforms = lib.platforms.linux;
  };
}
