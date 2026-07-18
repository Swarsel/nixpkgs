{
  lib,
  stdenv,
  fetchurl,
  makeDesktopItem,
  runtimeShell,
  scummvm,
  unzip,
  writeText,
}:

let
  desktopItem =
    name: short: long: description:
    makeDesktopItem {
      categories = [
        "Game"
        "AdventureGame"
      ];

      comment = description;
      desktopName = long;
      exec = "@out@/bin/${short}";
      genericName = description;
      icon = "scummvm";
      name = name;
    };

  run =
    name: short: code:
    writeText "${short}.sh" ''
      #!${runtimeShell} -eu

      exec ${scummvm}/bin/scummvm \
        --path=@out@/share/${name} \
        --fullscreen \
        ${code}
    '';

  generic =
    {
      description,
      files,
      pcode,
      plong,
      pshort,
      version,
      docs ? [ "readme.txt" ],
      ...
    }@attrs:
    let
      attrs' = removeAttrs attrs [
        "plong"
        "pshort"
        "pcode"
        "description"
        "docs"
        "files"
        "version"
      ];
      pname = lib.replaceStrings [ " " ":" ] [ "-" "" ] (lib.toLower plong);
    in
    stdenv.mkDerivation (
      {
        inherit pname version;
        nativeBuildInputs = [ unzip ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin $out/share/{applications,${pname},doc/${pname}}

          ${lib.concatStringsSep "\n" (map (f: "mv ${f} $out/share/doc/${pname}") docs)}
          ${lib.concatStringsSep "\n" (map (f: "mv ${f} $out/share/${pname}") files)}

          substitute ${run pname pshort pcode} $out/bin/${pshort} \
            --subst-var out
          substitute ${
            desktopItem pname pshort plong description
          }/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop \
            --subst-var out

          chmod 0755 $out/bin/${pshort}

          runHook postInstall
        '';

        dontBuild = true;
        dontFixup = true;

        meta = {
          inherit description;
          inherit (scummvm.meta) platforms;
          homepage = "https://www.scummvm.org";
          license = lib.licenses.free; # refer to the readme for exact wording
          maintainers = with lib.maintainers; [ peterhoeg ];
        };
      }
      // attrs'
    );

in
{
  beneath-a-steel-sky = generic rec {
    version = "1.2";

    src = fetchurl {
      url = "mirror://sourceforge/scummvm/${pshort}-cd-${version}.zip";
      sha256 = "14s5jz67kavm8l15gfm5xb7pbpn8azrv460mlxzzvdpa02a9n82k";
    };

    description = "2D point-and-click science fiction thriller set in a bleak vision of the future";
    files = [ "sky.*" ];
    pcode = "sky";
    plong = "Beneath a Steel Sky";
    pshort = "bass";
  };

  broken-sword-25 = generic rec {
    version = "1.0";

    src = fetchurl {
      url = "mirror://sourceforge/scummvm/${pshort}-v${version}.zip";
      sha256 = "0ivj1vflfpih5bs5a902mab88s4d77fwm3ya3fk7pammzc8gjqzz";
    };

    description = "Fan game of the Broken Sword series";

    docs = [
      "README"
      "license-original.txt"
    ];

    files = [ "data.b25c" ];
    pcode = "sword25";
    plong = "Broken Sword 2.5";
    pshort = "sword25";
    sourceRoot = ".";
  };

  drascula-the-vampire-strikes-back = generic rec {
    version = "1.0";

    # srcs = {
    src = fetchurl {
      url = "mirror://sourceforge/scummvm/${pshort}-${version}.zip";
      sha256 = "1pj29rpb754sn6a56f8brfv6f2m1p5qgaqik7d68pfi2bb5zccdp";
    };

    description = "Spanish 2D classic point & click style adventure with tons of humor and an easy interface";

    docs = [
      "readme.txt"
      "drascula.doc"
    ];

    files = [ "Packet.001" ];
    pcode = "drascula";
    plong = "Drascula: The Vampire Strikes Back";
    pshort = "drascula";
    # audio = fetchurl {
    # url = "mirror://sourceforge/scummvm/${pshort}-audio-flac-2.0.zip";
    # sha256 = "1zmqhrby8f5sj1qy6xjdgkvk9wyhr3nw8ljrrl58fmxb83x1rryw";
    # };
    # };
    sourceRoot = ".";
  };

  dreamweb = generic rec {
    version = "1.1";

    src = fetchurl {
      url = "mirror://sourceforge/scummvm/${pshort}-cd-uk-${version}.zip";
      sha256 = "0hh1p3rd7s0ckvri14lc6wdry9vv0vn4h4744v2n4zg63j8i6vsa";
    };

    description = "2D point-and-click cyberpunk top-down adventure game";
    docs = [ "license.txt" ];

    files = [
      "DREAMWEB.*"
      "SPEECH"
      "track01.flac"
    ];

    pcode = "dreamweb";
    plong = "Dreamweb";
    pshort = "dreamweb";
    sourceRoot = ".";
  };

  flight-of-the-amazon-queen = generic rec {
    version = "1.1";

    src = fetchurl {
      url = "mirror://sourceforge/scummvm/FOTAQ_Talkie-${version}.zip";
      sha256 = "1a6q71q1dl9vvw2qqsxk5h1sv0gaqy6236zr5905w2is01gdsp52";
    };

    description = "2D point-and-click adventure game set in the 1940s";
    files = [ "*.1c" ];
    pcode = "queen";
    plong = "Flight of the Amazon Queen";
    pshort = "fotaq";
    sourceRoot = ".";
  };

  lure-of-the-temptress = generic rec {
    version = "1.1";

    src = fetchurl {
      url = "mirror://sourceforge/scummvm/lure-${version}.zip";
      sha256 = "0201i70qcs1m797kvxjx3ygkhg6kcl5yf49sihba2ga8l52q45zk";
    };

    description = "2D point-and-click adventure game with a fantasy theme";

    docs = [
      "README"
      "*.txt"
      "*.pdf"
      "*.PDF"
    ];

    files = [ "*.vga" ];
    pcode = "lure";
    plong = "Lure of the Temptress";
    pshort = "lott";
  };
}
