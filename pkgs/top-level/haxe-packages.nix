{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  haxe,
  jdk,
  mono,
  neko,
}:

let
  withCommas = lib.replaceStrings [ "." ] [ "," ];

  installLibHaxe =
    {
      libname,
      version,
      files ? "*",
    }:
    ''
      mkdir -p "$out/lib/haxe/${withCommas libname}/${withCommas version}"
      echo -n "${version}" > $out/lib/haxe/${withCommas libname}/.current
      cp -dpR ${files} "$out/lib/haxe/${withCommas libname}/${withCommas version}/"
    '';

  buildHaxeLib =
    {
      libname,
      meta,
      sha256,
      version,
      ...
    }@attrs:
    stdenv.mkDerivation (
      attrs
      // {
        inherit version;
        pname = libname;

        src = fetchzip rec {
          inherit sha256;
          url = "http://lib.haxe.org/files/3.0/${withCommas name}.zip";
          name = "${libname}-${version}";
          stripRoot = false;
        };

        buildInputs = (attrs.buildInputs or [ ]) ++ [
          haxe
          neko
        ]; # for setup-hook.sh to work

        installPhase =
          attrs.installPhase or ''
            runHook preInstall
            (
              if [ $(ls $src | wc -l) == 1 ]; then
                cd $src/* || cd $src
              else
                cd $src
              fi
              ${installLibHaxe { inherit libname version; }}
            )
            runHook postInstall
          '';

        meta = {
          description = throw "please write meta.description";
          homepage = "http://lib.haxe.org/p/${libname}";
          license = lib.licenses.bsd2;
          platforms = lib.platforms.all;
        }
        // attrs.meta;
      }
    );
in
{
  format = buildHaxeLib {
    version = "3.5.0";
    libname = "format";
    sha256 = "sha256-5vZ7b+P74uGx0Gb7X/+jbsx5048dO/jv5nqCDtw5y/A=";
    meta.description = "Haxe library for supporting different file formats";
  };

  heaps = buildHaxeLib {
    version = "1.9.1";
    libname = "heaps";
    sha256 = "sha256-i5EIKnph80eEEHvGXDXhIL4t4+RW7OcUV5zb2f3ItlI=";
    meta.description = "GPU game framework";
  };

  hlopenal = buildHaxeLib {
    version = "1.5.0";
    libname = "hlopenal";
    sha256 = "sha256-mJWFGBJPPAhVwsB2HzMfk4szSyjMT4aw543YhVqIan4=";
    meta.description = "OpenAL support for Haxe/HL";
  };

  hlsdl = buildHaxeLib {
    version = "1.10.0";
    libname = "hlsdl";
    sha256 = "sha256-kmC2EMDy1mv0jFjwDj+m0CUvKal3V7uIGnMxJBRYGms=";
    meta.description = "SDL/GL support for Haxe/HL";
  };

  hxcpp = buildHaxeLib rec {
    version = "4.1.15";

    postFixup = ''
      for f in $out/lib/haxe/${withCommas libname}/${withCommas version}/{,project/libs/nekoapi/}bin/Linux{,64}/*; do
        chmod +w "$f"
        patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker)   "$f" || true
        patchelf --set-rpath ${lib.makeLibraryPath [ stdenv.cc.cc ]}  "$f" || true
      done
    '';

    libname = "hxcpp";
    sha256 = "1ybxcvwi4655563fjjgy6xv5c78grjxzadmi3l1ghds48k1rh50p";
    meta.description = "Runtime support library for the Haxe C++ backend";
  };

  hxcs = buildHaxeLib {
    version = "3.4.0";
    propagatedBuildInputs = [ mono ];
    libname = "hxcs";
    sha256 = "0f5vgp2kqnpsbbkn2wdxmjf7xkl0qhk9lgl9kb8d5wdy89nac6q6";
    meta.description = "Support library for the C# backend of the Haxe compiler";
  };

  hxjava = buildHaxeLib {
    version = "3.2.0";
    propagatedBuildInputs = [ jdk ];
    libname = "hxjava";
    sha256 = "1vgd7qvsdxlscl3wmrrfi5ipldmr4xlsiwnj46jz7n6izff5261z";
    meta.description = "Support library for the Java backend of the Haxe compiler";
  };

  hxnodejs_4 = buildHaxeLib {
    version = "4.0.9";
    libname = "hxnodejs";
    sha256 = "0b7ck48nsxs88sy4fhhr0x1bc8h2ja732zzgdaqzxnh3nir0bajm";
    meta.description = "Extern definitions for node.js 4.x";
  };

  hxnodejs_6 =
    let
      libname = "hxnodejs";
      version = "6.9.0";
    in
    stdenv.mkDerivation {
      src = fetchFromGitHub {
        owner = "HaxeFoundation";
        repo = "hxnodejs";
        rev = "cf80c6a077e705d39f752418e95555b346f4d9b2";
        sha256 = "0mdiacr5b2m8jrlgyd2d3vp1fha69lcfb67x4ix7l7zfi8g460gs";
      };

      installPhase = installLibHaxe { inherit libname version; };
      name = "${libname}-${version}";

      meta = {
        description = "Extern definitions for node.js 6.9";
        homepage = "http://lib.haxe.org/p/${libname}";
        license = lib.licenses.bsd2;
        platforms = lib.platforms.all;
      };
    };
}
