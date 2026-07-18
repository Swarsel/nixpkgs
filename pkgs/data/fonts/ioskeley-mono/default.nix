{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

let
  version = "v2.0.0";

  mkFont =
    {
      hash,
      width,
      hinted ? true,
      isNF ? false,
      variant ? "",
    }:
    let
      fileName = "IoskeleyMono${if variant != "" then "-${variant}" else ""}${
        if isNF then "-NerdFont" else ""
      }.zip";
      hintDir = if hinted then "Hinted" else "Unhinted";

      pname =
        let
          wPart = "-${lib.toLower width}";
          vPart = if variant != "" then "-${variant}" else "";
          nfPart = if isNF then "-NF" else "";
          hPart = if !hinted && !isNF then "-unhinted" else "";
        in
        "ioskeley-mono${wPart}${vPart}${nfPart}${hPart}";
    in
    stdenvNoCC.mkDerivation {
      inherit pname version;

      src = fetchzip {
        inherit hash;
        url = "https://github.com/ahatem/IoskeleyMono/releases/download/${version}/${fileName}";
        stripRoot = false;
      };

      nativeBuildInputs = [ installFonts ];
      sourceRoot = if isNF then "source/${width}" else "source/${width}/${hintDir}";

      meta = {
        description = "Iosevka configuration mimicking Berkeley Mono, ${width} width${
          if variant != "" then ", ${variant} variant" else ""
        }${if isNF then ", Nerd Font patched" else ""}${if !hinted then ", unhinted" else ""}";

        homepage = "https://github.com/ahatem/IoskeleyMono";
        license = lib.licenses.ofl;
        maintainers = with lib.maintainers; [ nuexq ];
        platforms = lib.platforms.all;
      };
    };

  allWidths = [
    "Normal"
    "SemiCondensed"
    "Condensed"
  ];

  mkWidths =
    {
      suffix ? "",
      withHinting ? false,
      ...
    }@args:
    let
      mkWidthSet =
        hinted:
        map (w: {
          name = "${lib.strings.toLower (builtins.substring 0 1 w)}${builtins.substring 1 (-1) w}${
            if suffix != "" then "-${suffix}" else ""
          }${if !hinted then "-unhinted" else ""}";

          value = mkFont (
            {
              inherit hinted;
              width = w;
            }
            // (removeAttrs args [
              "suffix"
              "withHinting"
            ])
          );
        }) allWidths;
    in
    lib.listToAttrs (
      if withHinting then
        lib.concatMap (h: mkWidthSet h) [
          true
          false
        ]
      else
        mkWidthSet true
    );
in

# Standard
mkWidths {
  hash = "sha256-EJDlA18XZPq7vhtpw/74n5s1NmTy0/DLu2oYB7OuvbA=";
  withHinting = true;
}

# Term
// mkWidths {
  hash = "sha256-E7I7gmu9EOaCKn4JOFkCjHP/I/1wadRkZoCxVfm+b1k=";
  suffix = "term";
  variant = "Term";
  withHinting = true;
}

// mkWidths {
  hash = "sha256-GiMI2YTl20K+zUObcFNzgP1ivm7pH2zHWFG15gFgasg=";
  isNF = true;
  suffix = "term-NF";
  variant = "Term";
}

# NL
// mkWidths {
  hash = "sha256-dNOpQJ1VOrjcKS/UtPXKUP9W0gaxFMvH4aa+xK2hg2w=";
  suffix = "NL";
  variant = "NL";
  withHinting = true;
}

// mkWidths {
  hash = "sha256-N7mtM/aQwps77u907z8Rop3RftRGR4K8zDXFX8xWq5w=";
  isNF = true;
  suffix = "NL-NF";
  variant = "NL";
}

# Nerd Font Standard
// mkWidths {
  hash = "sha256-Nt8EaVhKvlb9BMKQe4l5iNGcPLzKba6KScIWZbcL8gA=";
  isNF = true;
  suffix = "NF";
}
