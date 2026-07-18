{ lib, runCommand }:
runCommand "documentation-highlighter"
  {
    pname = "documentation-highlighter";
    version = "11.9.0";

    src = lib.sources.cleanSourceWith {
      filter =
        path: type:
        lib.elem (baseNameOf path) [
          "highlight.pack.js"
          "LICENSE"
          "loader.js"
          "mono-blue.css"
          "README.md"
        ];

      src = ./.;
    };

    meta = {
      description = "Highlight.js sources for the Nix Ecosystem's documentation";
      homepage = "https://highlightjs.org";
      license = lib.licenses.bsd3;
      platforms = lib.platforms.all;
    };
  }
  ''
    cp -r "$src" "$out"
  ''
