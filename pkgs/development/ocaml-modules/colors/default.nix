{
  lib,
  fetchurl,
  buildDunePackage,
  mdx,
  ocaml,
}:

buildDunePackage (finalAttrs: {
  pname = "colors";
  version = "0.0.1";

  src = fetchurl {
    url = "https://github.com/leostera/colors/releases/download/${finalAttrs.version}/colors-${finalAttrs.version}.tbz";
    hash = "sha256-fY1j9FODVnifwsI8qkKm0QSmssgWqYFXJ7y8o7/KmEY=";
  };

  doCheck = lib.versionAtLeast ocaml.version "5.1";

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    mdx
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Pure OCaml library for manipulating colors across color spaces";
    homepage = "https://github.com/leostera/colors";
    changelog = "https://github.com/leostera/colors/blob/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
