{
  lib,
  fetchzip,
  stdenvNoCC,
  symlinkJoin,
}:
let
  fonts = lib.importTOML ./fonts.toml;

  meta = {
    description = "Innovative superfamily of fonts for code";

    longDescription = ''
      Since the earliest days of the teletype machine, code has been set in
      monospaced type — letters, on a grid. Monaspace is a new type system that
      advances the state of the art for the display of code on screen.

      Every advancement in the technology of computing has been accompanied by
      advancements to the display and editing of code. CRTs made screen editors
      possible. The advent of graphical user interfaces gave rise to integrated
      development environments.

      Even today, we still have limited options when we want to layer additional
      meaning on top of code. Syntax highlighting was invented in 1982 to help
      children to code in BASIC. But beyond colors, most editors must
      communicate with developers through their interfaces — hovers, underlines,
      and other graphical decorations.

      Monaspace offers a more expressive palette for code and the tools we use
      to work with it.
    '';

    homepage = "https://monaspace.githubnext.com/";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };

  makeFont =
    {
      baseUrl,
      destination,
      fontFamily,
      hash,
      meta,
      pname,
      variant,
      version,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname version;
      inherit meta;

      src = fetchzip {
        inherit hash;
        url = "${baseUrl}/v${version}/${fontFamily}-${variant}-v${version}.zip";
      };

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/share/fonts/${destination}"
        find . -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.woff" \) -exec install -Dm644 {} $out/share/fonts/${destination} \;

        runHook postInstall
      '';
    };

  makePackages =
    filteredFonts:
    lib.listToAttrs (
      map (
        font:
        let
          fontAttrs = rec {
            inherit (fonts) baseUrl fontFamily version;
            inherit (font) variant hash destination;
            inherit meta;
            pname = fontFamily + "-" + variant;
          };
        in
        {
          name = fontAttrs.variant;
          value = makeFont fontAttrs;
        }
      ) filteredFonts
    );
  allFonts = makePackages fonts.fonts;
  woffFonts = makePackages (builtins.filter (f: f.destination == "woff") fonts.fonts);
  defaultFonts = lib.removeAttrs allFonts (builtins.attrNames woffFonts);
in
symlinkJoin {
  inherit (fonts) version;
  inherit meta;
  pname = "monaspace";
  paths = builtins.attrValues defaultFonts;

  passthru = allFonts // {
    woff = symlinkJoin {
      inherit (fonts) version;
      pname = "monaspace-webfonts";
      paths = builtins.attrValues woffFonts;
    };
  };
}
