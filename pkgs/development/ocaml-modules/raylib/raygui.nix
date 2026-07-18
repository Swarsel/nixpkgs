{
  fetchurl,
  buildDunePackage,
  raylib,
}:

buildDunePackage (finalAttrs: {
  inherit (raylib) patches;
  pname = "raygui";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/tjammer/raylib-ocaml/releases/download/${finalAttrs.version}/raygui-${finalAttrs.version}.tbz";
    hash = "sha256-PQcVTAQKeTPkOOHk5w3O3Tz0n7jLvkIo3Urvrk66eMs=";
  };

  propagatedBuildInputs = [
    raylib
  ];

  meta = raylib.meta // {
    description = "OCaml bindings for raygui";
  };
})
