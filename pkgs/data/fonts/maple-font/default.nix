{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let

  hashes = lib.importJSON ./hashes.json;

  maple-font =
    {
      desc,
      hash,
      pname,
    }:
    stdenv.mkDerivation rec {
      inherit pname;
      version = "7.9";

      src = fetchurl {
        inherit hash;
        url = "https://github.com/subframe7536/Maple-font/releases/download/v${version}/${pname}.zip";
      };

      nativeBuildInputs = [ unzip ];

      installPhase = ''
        find . -name '*.ttf'    -exec install -Dt $out/share/fonts/truetype {} \;
        find . -name '*.otf'    -exec install -Dt $out/share/fonts/opentype {} \;
        find . -name '*.woff2'  -exec install -Dt $out/share/fonts/woff2 {} \;
      '';

      # Work around the "unpacker appears to have produced no directories"
      # case that happens when the archive doesn't have a subdirectory.
      sourceRoot = ".";

      meta = {
        description = ''
          Open source ${desc} font with round corner and ligatures for IDE and command line
        '';

        homepage = "https://github.com/subframe7536/Maple-font";
        license = lib.licenses.ofl;
        maintainers = with lib.maintainers; [ oluceps ];
        platforms = lib.platforms.all;
      };
    };

  typeVariants = {
    CN = {
      desc = "monospace CN";
      suffix = "CN";
    };

    CN-unhinted = {
      desc = "monospace CN unhinted";
      suffix = "CN-unhinted";
    };

    NF = {
      desc = "Nerd Font";
      suffix = "NF";
    };

    NF-CN = {
      desc = "Nerd Font CN";
      suffix = "NF-CN";
    };

    NF-CN-unhinted = {
      desc = "Nerd Font CN unhinted";
      suffix = "NF-CN-unhinted";
    };

    NF-unhinted = {
      desc = "Nerd Font unhinted";
      suffix = "NF-unhinted";
    };

    opentype = {
      desc = "OpenType";
      suffix = "OTF";
    };

    truetype = {
      desc = "monospace TrueType";
      suffix = "TTF";
    };

    truetype-autohint = {
      desc = "monospace ttf autohint";
      suffix = "TTF-AutoHint";
    };

    variable = {
      desc = "monospace variable";
      suffix = "Variable";
    };

    woff2 = {
      desc = "WOFF2.0";
      suffix = "Woff2";
    };
  };

  ligatureVariants = {
    No-Ligature = {
      desc = "No Ligature";
      suffix = "NL";
    };

    Normal-Ligature = {
      desc = "Normal Ligature";
      suffix = "Normal";
    };

    Normal-No-Ligature = {
      desc = "Normal No Ligature";
      suffix = "NormalNL";
    };
  };

  combinedFonts =
    lib.concatMapAttrs (
      ligName: ligVariant:
      lib.concatMapAttrs (
        typeName: typeVariant:
        let
          pname = "MapleMono${ligVariant.suffix}-${typeVariant.suffix}";
        in
        {
          "${ligVariant.suffix}-${typeVariant.suffix}" = maple-font {
            inherit pname;
            desc = "${ligVariant.desc} ${typeVariant.desc}";
            hash = hashes.${pname};
          };
        }
      ) typeVariants
    ) ligatureVariants
    // lib.mapAttrs (
      _: value:
      let
        pname = "MapleMono-${value.suffix}";
      in
      maple-font {
        inherit pname;
        inherit (value) desc;
        hash = hashes.${pname};
      }
    ) typeVariants;
in
combinedFonts
