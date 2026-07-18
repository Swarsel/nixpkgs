{
  lib,
  fetchurl,
  buildDunePackage,
  ctypes,
  dune-configurator,
  fetchpatch,
  integers,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  patch,
}:

buildDunePackage (finalAttrs: {
  pname = "raylib";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/tjammer/raylib-ocaml/releases/download/${finalAttrs.version}/raylib-${finalAttrs.version}.tbz";
    hash = "sha256-/SeKgQOrhsAgMNk6ODAZlopL0mL0lVfCTx1ugmV1P/s=";
  };

  patches = [
    (fetchpatch {
      excludes = [
        "dune-project"
        "raygui.opam"
      ];

      hash = "sha256-MEZkkBgjL2iT6Av/s0tJCrW7+oyp9QD6sUbXEusCAWI=";
      name = "fix-build-with-patch-3.0.0.patch";
      url = "https://github.com/tjammer/raylib-ocaml/commit/40e6fef44e3c39d4526806c4b830da77c4fe4bb8.patch";
    })
  ];

  buildInputs = [
    dune-configurator
    patch
  ];

  propagatedBuildInputs = [
    ctypes
    integers
    libGL
    libx11
    libxcursor
    libxi
    libxinerama
    libxrandr
  ];

  meta = {
    description = "OCaml bindings for Raylib (5.0.0)";
    homepage = "https://tjammer.github.io/raylib-ocaml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ r17x ];
  };
})
