{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libbass,
  unzip,
}:

# Upstream changes files in-place, to update:
# 1. Check latest version at http://www.un4seen.com/
# 2. Update `version`s and `hash` sums.
# See also http://www.un4seen.com/forum/?topic=18614.0

# Internet Archive used due to upstream URLs being unstable

let
  allBass = {
    bass = {
      version = "2.4.18.3";
      buildInputs = [ ];

      h = {
        darwin = "c/bass.h";
        linux = "c/bass.h";
      };

      hash = {
        darwin = "sha256-363WI4iWsCsUSyhwZV+57iRF/ITVwA9+HFb6+TQ85Zw=";
        linux = "sha256-3iZk+9MaGn7vTbSNprjChICMXhk8Pu4hWHIR3peGkXI=";
      };

      so = {
        aarch64-darwin = "libbass.dylib";
        aarch64-linux = "libs/aarch64/libbass.so";
        armv7l-linux = "libs/armhf/libbass.so";
        i686_linux = "libs/x86/libbass.so";
        x86_64-linux = "libs/x86_64/libbass.so";
      };

      url = {
        darwin = "https://web.archive.org/web/20260318192647/https://www.un4seen.com/files/bass24-osx.zip";
        linux = "https://web.archive.org/web/20251222154947/https://www.un4seen.com/files/bass24-linux.zip";
      };
    };

    bass_fx = {
      version = "2.4.12.6";

      buildInputs = [
        libbass
        stdenv.cc.cc
      ];

      h = {
        darwin = "bass_fx.h";
        linux = "C/bass_fx.h";
      };

      hash = {
        darwin = "sha256-655JbaIpzdc9xR0Wx+P9F8dACoElwr4v64ju4axo3Gg=";
        linux = "sha256-Hul2ELwnaDV8TDRMDXoFisle31GATDkf3PdkR2K9QTs=";
      };

      so = {
        aarch64-darwin = "libbass_fx.dylib";
        aarch64-linux = "libs/aarch64/libbass_fx.so";
        armv7l-linux = "libs/armhf/libbass_fx.so";
        i686_linux = "libs/x86/libbass_fx.so";
        x86_64-linux = "libs/x86_64/libbass_fx.so";
      };

      url = {
        darwin = "https://web.archive.org/web/20250927051000/https://www.un4seen.com/files/z/0/bass_fx24-osx.zip";
        linux = "https://web.archive.org/web/20250627192213/https://www.un4seen.com/files/z/0/bass_fx24-linux.zip";
      };
    };

    bassmidi = {
      version = "2.4.15.3";
      buildInputs = [ libbass ];

      h = {
        darwin = "bassmidi.h";
        linux = "bassmidi.h";
      };

      hash = {
        darwin = "sha256-Sqr83pSEv6hGGxgzEBLSg56sLR2QiPLazp0cmKz1vis=";
        linux = "sha256-HrF1chhGk32bKN3jwal44Tz/ENGe/zORsrLPeGAv1OE=";
      };

      so = {
        aarch64-darwin = "libbassmidi.dylib";
        aarch64-linux = "libs/aarch64/libbassmidi.so";
        armv7l-linux = "libs/armhf/libbassmidi.so";
        i686_linux = "libs/x86/libbassmidi.so";
        x86_64-linux = "libs/x86_64/libbassmidi.so";
      };

      url = {
        darwin = "https://web.archive.org/web/20260318193855/https://www.un4seen.com/files/bassmidi24-osx.zip";
        linux = "https://web.archive.org/web/20240501180447/http://www.un4seen.com/files/bassmidi24-linux.zip";
      };
    };

    bassmix = {
      version = "2.4.12";
      buildInputs = [ libbass ];

      h = {
        darwin = "bassmix.h";
        linux = "bassmix.h";
      };

      hash = {
        darwin = "sha256-HSu/R7JmPqJfr4jv6MthsdT+7okKm3EYe7+KdR9zSz0=";
        linux = "sha256-oxxBhsjeLvUodg2SOMDH4wUy5na3nxLTqYkB+iXbOgA=";
      };

      so = {
        aarch64-darwin = "libbassmix.dylib";
        aarch64-linux = "libs/aarch64/libbassmix.so";
        armv7l-linux = "libs/armhf/libbassmix.so";
        i686_linux = "libs/x86/libbassmix.so";
        x86_64-linux = "libs/x86_64/libbassmix.so";
      };

      url = {
        darwin = "https://web.archive.org/web/20260318194151/https://www.un4seen.com/files/bassmix24-osx.zip";
        linux = "https://web.archive.org/web/20240930183631/https://www.un4seen.com/files/bassmix24-linux.zip";
      };
    };
  };

  dropBass =
    name: bass:
    stdenv.mkDerivation {
      inherit (bass) version;
      pname = "lib${name}";

      src = fetchurl {
        url = bass.url.${stdenv.hostPlatform.parsed.kernel.name};
        hash = bass.hash.${stdenv.hostPlatform.parsed.kernel.name};
      };

      nativeBuildInputs = [ unzip ] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
      buildInputs = lib.optionals stdenv.hostPlatform.isLinux bass.buildInputs;

      installPhase =
        let
          so =
            if bass.so ? ${stdenv.hostPlatform.system} then
              bass.so.${stdenv.hostPlatform.system}
            else
              throw "${name} not packaged for ${stdenv.hostPlatform.system} (yet).";
        in
        ''
          mkdir -p $out/{lib,include}
          install -m644 -t $out/lib/ ${so}
          install -m644 -t $out/include/ ${bass.h.${stdenv.hostPlatform.parsed.kernel.name}}
        '';

      dontBuild = true;

      unpackCmd = ''
        mkdir out
        unzip $curSrc -d out
      '';

      meta = {
        description = "Shareware audio library";
        homepage = "https://www.un4seen.com/";
        license = lib.licenses.unfreeRedistributable;

        maintainers = with lib.maintainers; [
          poz
          ulysseszhan
        ];

        platforms = builtins.attrNames bass.so;
      };
    };

in
lib.mapAttrs dropBass allBass
