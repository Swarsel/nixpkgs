{
  lib,
  stdenv,
  fetchurl,
  config,
  acceptLicense ? config.joypixels.acceptLicense or false,
}:

let
  inherit (stdenv.hostPlatform.parsed) kernel;

  systemSpecific =
    {
      darwin = rec {
        capitalized = systemTag;
        fontFile = "JoyPixels-SBIX.ttf";
        systemTag = "nix-darwin";
      };
    }
    .${kernel.name} or {
      capitalized = "NixOS";
      fontFile = "joypixels-android.ttf";
      systemTag = "nixos";
    };

  joypixels-free-license = {
    free = false;
    fullName = "JoyPixels Free License Agreement";
    spdxId = "LicenseRef-JoyPixels-Free";
    url = "https://cdn.joypixels.com/free-license.pdf";
  };

  joypixels-license-appendix = with systemSpecific; {
    free = false;
    fullName = "JoyPixels ${capitalized} License Appendix";
    spdxId = "LicenseRef-JoyPixels-NixOS-Appendix";
    url = "https://cdn.joypixels.com/distributions/${systemTag}/appendix/joypixels-license-appendix.pdf";
  };

  throwLicense = throw ''
    Use of the JoyPixels font requires acceptance of the license.
      - ${joypixels-free-license.fullName} [1]
      - ${joypixels-license-appendix.fullName} [2]

    You can express acceptance by setting acceptLicense to true in your
    configuration. Note that this is not a free license so it requires allowing
    unfree licenses.

    configuration.nix:
      nixpkgs.config.allowUnfreePackages = [
        "joypixels"
      ];
      nixpkgs.config.joypixels.acceptLicense = true;

    config.nix:
      allowUnfreePackages = [
        "joypixels"
      ];
      joypixels.acceptLicense = true;

    [1]: ${joypixels-free-license.url}
    [2]: ${joypixels-license-appendix.url}
  '';

in

stdenv.mkDerivation rec {
  pname = "joypixels";
  version = "9.0.0";

  src =
    assert !acceptLicense -> throwLicense;
    with systemSpecific;
    fetchurl {
      url = "https://cdn.joypixels.com/distributions/${systemTag}/font/${version}/${fontFile}";

      sha256 =
        {
          darwin = "sha256-muUxXzz8BePyPsiZocYvM0ebM1H+u84ysN5YUvsMLiU=";
        }
        .${kernel.name} or "sha256-pmGsVgYSK/c5OlhOXhNlRBs/XppMXmsHcZeSmIkuED4=";

      name = fontFile;
    };

  installPhase = with systemSpecific; ''
    runHook preInstall

    install -Dm644 $src $out/share/fonts/truetype/${fontFile}

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Finest emoji you can use legally (formerly EmojiOne)";

    longDescription = ''
      Updated for 2024! JoyPixels 9.0 includes 3,820 originally crafted icon
      designs and is 100% Unicode 15.1 compatible. We offer the largest
      selection of files ranging from png, svg, iconjar, and fonts (sprites
      available upon request).
    '';

    homepage = "https://www.joypixels.com/fonts";

    license =
      let
        free-license = joypixels-free-license;
        appendix = joypixels-license-appendix;
      in
      with systemSpecific;
      {
        appendixUrl = appendix.url;
        free = false;
        fullName = "${free-license.fullName} with ${appendix.fullName}";
        redistributable = true;
        spdxId = "LicenseRef-JoyPixels-Free-with-${capitalized}-Appendix";
        url = free-license.url;
      };

    # Not quite accurate since it's a font, not a program, but clearly
    # indicates we're not actually building it from source.
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      toonn
      jtojnar
    ];

    hydraPlatforms = [ ]; # Just a binary file download, nothing to cache.
  };
}
