# hunspell dictionaries

{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  bash,
  coreutils,
  fetchzip,
  hunspell,
  ispell,
  perl,
  python3,
  unzip,
  which,
  zip,
}:

let
  mkDict =
    {
      dictFileName,
      pname,
      readmeFile,
      ...
    }@args:
    stdenv.mkDerivation (
      {
        inherit pname;

        installPhase = ''
          runHook preInstall
          # hunspell dicts
          install -dm755 "$out/share/hunspell"
          install -m644 ${dictFileName}.dic "$out/share/hunspell/"
          install -m644 ${dictFileName}.aff "$out/share/hunspell/"
          # myspell dicts symlinks
          install -dm755 "$out/share/myspell/dicts"
          ln -sv "$out/share/hunspell/${dictFileName}.dic" "$out/share/myspell/dicts/"
          ln -sv "$out/share/hunspell/${dictFileName}.aff" "$out/share/myspell/dicts/"
          # docs
          install -dm755 "$out/share/doc"
          install -m644 ${readmeFile} $out/share/doc/${pname}.txt
          runHook postInstall
        '';
      }
      // args
    );

  mkDictFromRla =
    {
      dictFileName,
      shortDescription,
      shortName,
    }:
    mkDict rec {
      inherit dictFileName;
      pname = "hunspell-dict-${shortName}-rla";
      version = "2.5";

      src = fetchFromGitHub {
        owner = "sbosio";
        repo = "rla-es";
        rev = "v${version}";
        sha256 = "sha256-oGnxOGHzDogzUMZESydIxRTbq9Dmd03flwHx16AK1yk=";
      };

      postPatch = ''
        substituteInPlace ortograf/herramientas/make_dict.sh \
           --replace /bin/bash ${bash}/bin/bash \
           --replace /dev/stderr stderr.log

        substituteInPlace ortograf/herramientas/remover_comentarios.sh \
           --replace /bin/bash ${bash}/bin/bash
      '';

      nativeBuildInputs = [
        bash
        coreutils
        which
        zip
        unzip
      ];

      buildPhase = ''
        cd ortograf/herramientas
        bash -x ./make_dict.sh -l ${dictFileName} -2
        unzip ${dictFileName}.zip \
          ${dictFileName}.dic ${dictFileName}.aff ${readmeFile}
      '';

      readmeFile = "README.txt";

      meta = {
        description = "Hunspell dictionary for ${shortDescription} from rla";
        homepage = "https://github.com/sbosio/rla-es";

        license = with lib.licenses; [
          gpl3
          lgpl3
          mpl11
        ];

        maintainers = with lib.maintainers; [ renzo ];
        platforms = lib.platforms.all;
      };
    };

  mkDictFromDSSO =
    {
      dictFileName,
      shortDescription,
      shortName,
    }:
    mkDict rec {
      inherit dictFileName;
      pname = "hunspell-dict-${shortName}-dsso";
      version = "2.40";

      src = fetchurl {
        url = "https://extensions.libreoffice.org/extensions/swedish-spelling-dictionary-den-stora-svenska-ordlistan/${version}/@@download/file/${_name}.oxt";
        sha256 = "b982881cc75f5c4af1199535bd4735ee476bdc48edf63e3f05fb4f715654a7bc";
      };

      nativeBuildInputs = [ unzip ];

      installPhase = ''
        # hunspell dicts
        install -dm755 "$out/share/hunspell"
        install -m644 dictionaries/${dictFileName}.dic "$out/share/hunspell/"
        install -m644 dictionaries/${dictFileName}.aff "$out/share/hunspell/"
        # myspell dicts symlinks
        install -dm755 "$out/share/myspell/dicts"
        ln -sv "$out/share/hunspell/${dictFileName}.dic" "$out/share/myspell/dicts/"
        ln -sv "$out/share/hunspell/${dictFileName}.aff" "$out/share/myspell/dicts/"
        # docs
        install -dm755 "$out/share/doc"
        install -m644 ${readmeFile} $out/share/doc/${pname}.txt
      '';

      _name = "ooo_swedish_dict_${_version}";
      # Should really use a string function or something
      _version = "2-40";
      readmeFile = "LICENSE_en_US.txt";
      sourceRoot = ".";

      unpackCmd = ''
        unzip $src dictionaries/${dictFileName}.dic dictionaries/${dictFileName}.aff $readmeFile
      '';

      meta = {
        description = "Hunspell dictionary for ${shortDescription} from LibreOffice";

        longDescription = ''
          Svensk ordlista baserad på DSSO (den stora svenska ordlistan) och Göran
          Anderssons (goran@init.se) arbete med denna. Ordlistan hämtas från
          LibreOffice då dsso.se inte längre verkar vara med oss.
        '';

        license = lib.licenses.lgpl3;
        platforms = lib.platforms.all;
      };
    };

  mkDictFromDicollecte =
    {
      dictFileName,
      longDescription,
      shortDescription,
      shortName,
      isDefault ? false,
    }:
    mkDict rec {
      inherit dictFileName;
      pname = "hunspell-dict-${shortName}-dicollecte";
      version = "5.3";

      src = fetchurl {
        url = "http://www.dicollecte.org/download/fr/hunspell-french-dictionaries-v${version}.zip";
        sha256 = "0ca7084jm7zb1ikwzh1frvpb97jn27i7a5d48288h2qlfp068ik0";
      };

      nativeBuildInputs = [ unzip ];

      postInstall = lib.optionalString isDefault ''
        for ext in aff dic; do
          ln -sv $out/share/hunspell/${dictFileName}.$ext $out/share/hunspell/fr_FR.$ext
          ln -sv $out/share/myspell/dicts/${dictFileName}.$ext $out/share/myspell/dicts/fr_FR.$ext
        done
      '';

      readmeFile = "README_dict_fr.txt";
      sourceRoot = ".";

      unpackCmd = ''
        unzip $src ${dictFileName}.dic ${dictFileName}.aff ${readmeFile}
      '';

      meta = {
        inherit longDescription;
        description = "Hunspell dictionary for ${shortDescription} from Dicollecte";
        homepage = "https://www.dicollecte.org/home.php?prj=fr";
        license = lib.licenses.mpl20;
        maintainers = with lib.maintainers; [ renzo ];
        platforms = lib.platforms.all;
      };
    };

  mkDictFromWordlist =
    {
      dictFileName,
      shortDescription,
      shortName,
      src,
      srcFileName,
    }:
    mkDict rec {
      inherit src srcFileName dictFileName;
      pname = "hunspell-dict-${shortName}-wordlist";
      version = "2026.02.25";
      nativeBuildInputs = [ unzip ];

      postUnpack = ''
        mv ${srcFileName}.dic ${dictFileName}.dic || true
        mv ${srcFileName}.aff ${dictFileName}.aff || true
        mv ${srcReadmeFile} ${readmeFile}         || true
      '';

      readmeFile = "README_" + dictFileName + ".txt";
      sourceRoot = ".";
      srcReadmeFile = "README_" + srcFileName + ".txt";

      unpackCmd = ''
        unzip $src ${srcFileName}.dic ${srcFileName}.aff ${srcReadmeFile}
      '';

      meta = {
        description = "Hunspell dictionary for ${shortDescription} from Wordlist";
        homepage = "http://wordlist.aspell.net/";
        license = lib.licenses.bsd3;
        maintainers = with lib.maintainers; [ renzo ];
        platforms = lib.platforms.all;
      };
    };

  mkDictFromLinguistico =
    {
      dictFileName,
      shortDescription,
      shortName,
      src,
    }:
    mkDict rec {
      inherit src dictFileName;
      pname = "hunspell-dict-${shortName}-linguistico";
      version = "2.4";
      nativeBuildInputs = [ unzip ];

      prePatch = ''
        # Fix dic file empty lines (FS#22275)
        sed '/^\/$/d' -i ${dictFileName}.dic
      '';

      readmeFile = dictFileName + "_README.txt";
      sourceRoot = ".";

      unpackCmd = ''
        unzip $src ${dictFileName}.dic ${dictFileName}.aff ${readmeFile}
      '';

      meta = {
        description = "Hunspell dictionary for ${shortDescription}";
        homepage = "https://sourceforge.net/projects/linguistico/";
        license = lib.licenses.gpl3;
        maintainers = with lib.maintainers; [ renzo ];
        platforms = lib.platforms.all;
      };
    };

  mkDictFromXuxen =
    {
      dictFileName,
      longDescription,
      shortDescription,
      shortName,
      srcs,
    }:
    stdenv.mkDerivation {
      inherit srcs;
      pname = "hunspell-dict-${shortName}-xuxen";
      version = "5-2015.11.10";

      installPhase = ''
        # hunspell dicts
        install -dm755 "$out/share/hunspell"
        install -m644 ${dictFileName}.dic "$out/share/hunspell/"
        install -m644 ${dictFileName}.aff "$out/share/hunspell/"
        # myspell dicts symlinks
        install -dm755 "$out/share/myspell/dicts"
        ln -sv "$out/share/hunspell/${dictFileName}.dic" "$out/share/myspell/dicts/"
        ln -sv "$out/share/hunspell/${dictFileName}.aff" "$out/share/myspell/dicts/"
      '';

      sourceRoot = ".";
      # Copy files stripping until first dash (path and hash)
      unpackCmd = "cp $curSrc \${curSrc##*-}";

      meta = {
        description = shortDescription;
        longDescription = longDescription;
        homepage = "https://xuxen.eus/";
        license = lib.licenses.gpl2;
        maintainers = with lib.maintainers; [ zalakain ];
        platforms = lib.platforms.all;
      };
    };

  mkDictFromJ3e =
    {
      dictFileName,
      shortDescription,
      shortName,
    }:
    stdenv.mkDerivation rec {
      pname = "hunspell-dict-${shortName}-j3e";
      version = "20161207";

      src = fetchurl {
        url = "https://j3e.de/ispell/igerman98/dict/igerman98-${version}.tar.bz2";
        sha256 = "1a3055hp2bc4q4nlg3gmg0147p3a1zlfnc65xiv2v9pyql1nya8p";
      };

      nativeBuildInputs = [
        ispell
        perl
        hunspell
      ];

      installPhase = ''
        patchShebangs bin
        make hunspell/${dictFileName}.aff hunspell/${dictFileName}.dic
        # hunspell dicts
        install -dm755 "$out/share/hunspell"
        install -m644 hunspell/${dictFileName}.dic "$out/share/hunspell/"
        install -m644 hunspell/${dictFileName}.aff "$out/share/hunspell/"
        # myspell dicts symlinks
        install -dm755 "$out/share/myspell/dicts"
        ln -sv "$out/share/hunspell/${dictFileName}.dic" "$out/share/myspell/dicts/"
        ln -sv "$out/share/hunspell/${dictFileName}.aff" "$out/share/myspell/dicts/"
      '';

      dontBuild = true;

      meta = {
        description = shortDescription;
        homepage = "https://www.j3e.de/ispell/igerman98/index_en.html";

        license = with lib.licenses; [
          gpl2
          gpl3
        ];

        maintainers = with lib.maintainers; [ timor ];
        platforms = lib.platforms.all;
      };
    };

  mkDictFromLibreOffice =
    {
      dictFileName,
      license,
      shortDescription,
      shortName,
      readmeFile ? "README_${dictFileName}.txt",
      sourceRoot ? dictFileName,
    }:
    mkDict rec {
      inherit dictFileName readmeFile;
      pname = "hunspell-dict-${shortName}-libreoffice";
      version = "6.3.0.4";

      src = fetchFromGitHub {
        owner = "LibreOffice";
        repo = "dictionaries";
        rev = "libreoffice-${version}";
        sha256 = "14z4b0grn7cw8l9s7sl6cgapbpwhn1b3gwc3kn6b0k4zl3dq7y63";
      };

      buildPhase = ''
        cp -a ${sourceRoot}/* .
      '';

      meta = {
        description = "Hunspell dictionary for ${shortDescription} from LibreOffice";
        homepage = "https://wiki.documentfoundation.org/Development/Dictionaries";
        license = license;
        maintainers = with lib.maintainers; [ vlaci ];
        platforms = lib.platforms.all;
      };
    };

in
rec {

  cs-cz = mkDictFromLibreOffice {
    dictFileName = "cs_CZ";
    license = with lib.licenses; [ gpl2 ];
    readmeFile = "README_cs.txt";
    shortDescription = "Czech (Czechia)";
    shortName = "cs-cz";
  };

  # CZECH
  cs_CZ = cs-cz;

  cy-gb = mkDict rec {
    pname = "hunspell-dict-cy-gb";
    version = "25.03";

    src = fetchFromGitHub {
      owner = "techiaith";
      repo = "hunspell-cy";
      tag = version;
      hash = "sha256-T1p0LbCUTKN7xfogbI2RqxdONgcMxDpjjFW+dN8IGa4=";
    };

    dictFileName = "cy_GB";
    readmeFile = "README.md";
    shortName = "cy-GB";

    meta = {
      description = "Hunspell dictionary for Welsh (Cymraeg)";
      homepage = "https://github.com/techiaith/hunspell-cy";

      license = with lib.licenses; [
        lgpl3
      ];

      maintainers = with lib.maintainers; [
        fin-w
      ];
    };
  };

  # According to https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes
  # we should use `cy` for Cymraeg but it's cy_GB in Hunspell.
  # WELSH / CYMRAEG
  cy_GB = cy-gb;

  da-dk = mkDict rec {
    pname = "hunspell-dict-da-dk";
    version = "2.5.189";

    src = fetchurl {
      url = "https://stavekontrolden.dk/dictionaries/da_DK/da_DK-${version}.oxt";
      sha256 = "sha256:0i1cw0nfg24b0sg2yc3q7315ng5vc5245nvh0l1cndkn2c9z4978";
    };

    nativeBuildInputs = [ unzip ];
    dictFileName = "da_DK";
    readmeFile = "README_da_DK.txt";
    shortDescription = "Danish (Danmark)";
    shortName = "da-dk";

    unpackCmd = ''
      unzip $src ${dictFileName}.dic ${dictFileName}.aff ${readmeFile} -d ${dictFileName}
    '';

    meta = {
      description = "Hunspell dictionary for Danish (Denmark) from Stavekontrolden";
      homepage = "https://github.com/jeppebundsgaard/stavekontrolden";

      license = with lib.licenses; [
        gpl2Only
        lgpl21Only
        mpl11
      ];

      maintainers = with lib.maintainers; [ louisdk1 ];
    };
  };

  # DANISH
  da_DK = da-dk;

  de-at = mkDictFromJ3e {
    dictFileName = "de_AT";
    shortDescription = "German (Austria)";
    shortName = "de-at";
  };

  de-ch = mkDictFromJ3e {
    dictFileName = "de_CH";
    shortDescription = "German (Switzerland)";
    shortName = "de-ch";
  };

  de-de = mkDictFromJ3e {
    dictFileName = "de_DE";
    shortDescription = "German (Germany)";
    shortName = "de-de";
  };

  de_AT = de-at;
  de_CH = de-ch;
  # GERMAN
  de_DE = de-de;

  el-gr = mkDictFromLibreOffice {
    dictFileName = "el_GR";

    license = with lib.licenses; [
      mpl11
      gpl2
      lgpl21
    ];

    readmeFile = "README_el_GR.txt";
    shortDescription = "Greek (Greece)";
    shortName = "el-gr";
  };

  # GREEK
  el_GR = el-gr;

  en-au = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_AU-2026.02.25.zip";
      hash = "sha256-+FRxWTuXRPZCmMAtB/ti1Ykmv4H7XkVS4rrGRb+kAeA=";
    };

    dictFileName = "en_AU";
    shortDescription = "English (Australia)";
    shortName = "en-au";
    srcFileName = "en_AU";
  };

  en-au-large = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_AU-large-2026.02.25.zip";
      hash = "sha256-RqJliD0dAciJtxc7ocq64MqRWqQD1qL5PO5MxmEIfbQ=";
    };

    dictFileName = "en_AU";
    shortDescription = "English (Australia) Large";
    shortName = "en-au-large";
    srcFileName = "en_AU-large";
  };

  en-ca = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_CA-2026.02.25.zip";
      hash = "sha256-Kf4AUECMNWFPIr6oQzi0JWliyJ9e8l2sUDgyW8uG9CQ=";
    };

    dictFileName = "en_CA";
    shortDescription = "English (Canada)";
    shortName = "en-ca";
    srcFileName = "en_CA";
  };

  en-ca-large = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_CA-large-2026.02.25.zip";
      hash = "sha256-tLe/SniF3hw1+hs6poMXIJr6WPBNYOigfhJGk0hcWeM=";
    };

    dictFileName = "en_CA";
    shortDescription = "English (Canada) Large";
    shortName = "en-ca-large";
    srcFileName = "en_CA-large";
  };

  en-gb-ise = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_GB-ise-2026.02.25.zip";
      hash = "sha256-1vu5GueCTFL7AvdNe8LNkJLxMPrsYPQjJqWUN/pyR6M=";
    };

    dictFileName = "en_GB";
    shortDescription = "English (United Kingdom, 'ise' ending)";
    shortName = "en-gb-ise";
    srcFileName = "en_GB-ise";
  };

  en-gb-ize = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_GB-ize-2026.02.25.zip";
      hash = "sha256-xb3ZL8HiHadQOTn+QTnzbyjwHBisNeL8kLUmobe/sJk=";
    };

    dictFileName = "en_GB";
    shortDescription = "English (United Kingdom, 'ize' ending)";
    shortName = "en-gb-ize";
    srcFileName = "en_GB-ize";
  };

  en-gb-large = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_GB-large-2026.02.25.zip";
      hash = "sha256-cEpJQ4o6nU8RzXbbQzprIwuc6HcO4T+ihwAFLEUX3cE=";
    };

    dictFileName = "en_GB";
    shortDescription = "English (United Kingdom) Large";
    shortName = "en-gb-large";
    srcFileName = "en_GB-large";
  };

  en-us = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_US-2026.02.25.zip";
      hash = "sha256-rI5zMQ6VHYjFLCzyulTOrKNPhIaoFjCsinXcX5MRefk=";
    };

    dictFileName = "en_US";
    shortDescription = "English (United States)";
    shortName = "en-us";
    srcFileName = "en_US";
  };

  en-us-large = mkDictFromWordlist {
    src = fetchurl {
      url = "mirror://sourceforge/wordlist/speller/2026.02.25/hunspell-en_US-large-2026.02.25.zip";
      hash = "sha256-BqtaKhLCkDPxAJiNOwpeU9ytQL8kc8y3gnBhnR2pkyE=";
    };

    dictFileName = "en_US";
    shortDescription = "English (United States) Large";
    shortName = "en-us-large";
    srcFileName = "en_US-large";
  };

  en_AU = en-au;
  en_AU-large = en-au-large;
  en_CA = en-ca;
  en_CA-large = en-ca-large;
  en_GB-ise = en-gb-ise;
  en_GB-ize = en-gb-ize;
  en_GB-large = en-gb-large;
  # ENGLISH
  en_US = en-us;
  en_US-large = en-us-large;

  es-any = mkDictFromRla {
    dictFileName = "es_ANY";
    shortDescription = "Spanish (any variant)";
    shortName = "es-any";
  };

  es-ar = mkDictFromRla {
    dictFileName = "es_AR";
    shortDescription = "Spanish (Argentina)";
    shortName = "es-ar";
  };

  es-bo = mkDictFromRla {
    dictFileName = "es_BO";
    shortDescription = "Spanish (Bolivia)";
    shortName = "es-bo";
  };

  es-cl = mkDictFromRla {
    dictFileName = "es_CL";
    shortDescription = "Spanish (Chile)";
    shortName = "es-cl";
  };

  es-co = mkDictFromRla {
    dictFileName = "es_CO";
    shortDescription = "Spanish (Colombia)";
    shortName = "es-co";
  };

  es-cr = mkDictFromRla {
    dictFileName = "es_CR";
    shortDescription = "Spanish (Costa Rica)";
    shortName = "es-cr";
  };

  es-cu = mkDictFromRla {
    dictFileName = "es_CU";
    shortDescription = "Spanish (Cuba)";
    shortName = "es-cu";
  };

  es-do = mkDictFromRla {
    dictFileName = "es_DO";
    shortDescription = "Spanish (Dominican Republic)";
    shortName = "es-do";
  };

  es-ec = mkDictFromRla {
    dictFileName = "es_EC";
    shortDescription = "Spanish (Ecuador)";
    shortName = "es-ec";
  };

  es-es = mkDictFromRla {
    dictFileName = "es_ES";
    shortDescription = "Spanish (Spain)";
    shortName = "es-es";
  };

  es-gt = mkDictFromRla {
    dictFileName = "es_GT";
    shortDescription = "Spanish (Guatemala)";
    shortName = "es-gt";
  };

  es-hn = mkDictFromRla {
    dictFileName = "es_HN";
    shortDescription = "Spanish (Honduras)";
    shortName = "es-hn";
  };

  es-mx = mkDictFromRla {
    dictFileName = "es_MX";
    shortDescription = "Spanish (Mexico)";
    shortName = "es-mx";
  };

  es-ni = mkDictFromRla {
    dictFileName = "es_NI";
    shortDescription = "Spanish (Nicaragua)";
    shortName = "es-ni";
  };

  es-pa = mkDictFromRla {
    dictFileName = "es_PA";
    shortDescription = "Spanish (Panama)";
    shortName = "es-pa";
  };

  es-pe = mkDictFromRla {
    dictFileName = "es_PE";
    shortDescription = "Spanish (Peru)";
    shortName = "es-pe";
  };

  es-pr = mkDictFromRla {
    dictFileName = "es_PR";
    shortDescription = "Spanish (Puerto Rico)";
    shortName = "es-pr";
  };

  es-py = mkDictFromRla {
    dictFileName = "es_PY";
    shortDescription = "Spanish (Paraguay)";
    shortName = "es-py";
  };

  es-sv = mkDictFromRla {
    dictFileName = "es_SV";
    shortDescription = "Spanish (El Salvador)";
    shortName = "es-sv";
  };

  es-uy = mkDictFromRla {
    dictFileName = "es_UY";
    shortDescription = "Spanish (Uruguay)";
    shortName = "es-uy";
  };

  es-ve = mkDictFromRla {
    dictFileName = "es_VE";
    shortDescription = "Spanish (Venezuela)";
    shortName = "es-ve";
  };

  # SPANISH
  es_ANY = es-any;
  es_AR = es-ar;
  es_BO = es-bo;
  es_CL = es-cl;
  es_CO = es-co;
  es_CR = es-cr;
  es_CU = es-cu;
  es_DO = es-do;
  es_EC = es-ec;
  es_ES = es-es;
  es_GT = es-gt;
  es_HN = es-hn;
  es_MX = es-mx;
  es_NI = es-ni;
  es_PA = es-pa;
  es_PE = es-pe;
  es_PR = es-pr;
  es_PY = es-py;
  es_SV = es-sv;
  es_UY = es-uy;
  es_VE = es-ve;

  et-ee = mkDict rec {
    pname = "hunspell-dict-et-ee";
    version = "20030606";

    src = fetchzip {
      url = "http://www.meso.ee/~jjpp/speller/ispell-et_${version}.tar.gz";
      sha256 = "sha256-MVfKekzq2RKZONsz2Ey/xSRlh2bln46YO5UdGNkFdxk=";
    };

    preInstall = ''
      mv latin-1/${dictFileName}.dic ./
      mv latin-1/${dictFileName}.aff ./
    '';

    dictFileName = "et_EE";
    name = pname;
    readmeFile = "README";
  };

  # ESTONIAN
  et_EE = et-ee;

  eu-es = mkDictFromXuxen {
    dictFileName = "eu_ES";

    longDescription = ''
      Itxura berritzeaz gain, testuak zuzentzen laguntzeko zenbait hobekuntza
      egin dira Xuxen.eus-en. Lexikoari dagokionez, 18645 sarrera berri erantsi
      ditugu, eta proposamenak egiteko sistema ere aldatu dugu. Esate baterako,
      gaizki idatzitako hitz baten inguruko proposamenak eskuratzeko, euskaraz
      idaztean egiten ditugun akats arruntenak hartu dira kontuan. Sistemak
      ematen dituen proposamenak ordenatzeko, berriz, aipatutako irizpidea
      erabiltzeaz gain, Internetetik automatikoki eskuratutako euskarazko corpus
      bateko datuen arabera ordenatu daitezke emaitzak. Erabiltzaileak horrela
      ordenatu nahi baditu proposamenak, hautatu egin behar du aukera hori
      testu-kutxaren azpian dituen aukeren artean. Interesgarria da proposamenak
      ordenatzeko irizpide hori, hala sistemak formarik erabilienak proposatuko
      baitizkigu gutxiago erabiltzen direnen aurretik.
    '';

    shortDescription = "Basque (Xuxen 5)";
    shortName = "eu-es";

    srcs = [
      (fetchurl {
        sha256 = "12w2j6phzas2rdzc7f20jnk93sm59m2zzfdgxv6p8nvcvbrkmc02";
        url = "http://xuxen.eus/static/hunspell/eu_ES.aff";
      })
      (fetchurl {
        sha256 = "0lw193jr7ldvln5x5z9p21rz1by46h0say9whfcw2kxs9vprd5b3";
        url = "http://xuxen.eus/static/hunspell/eu_ES.dic";
      })
    ];
  };

  # BASQUE
  eu_ES = eu-es;

  fa-ir = mkDict {
    pname = "hunspell-dict-fa-ir";
    version = "experimental-2022-09-04";

    src = fetchFromGitHub {
      owner = "b00f";
      repo = "lilak";
      rev = "1a80a8e5c9377ac424d29ef20be894e250bc9765";
      hash = "sha256-xonnrclzgFEHdQ9g8ijm0bo9r5a5Y0va52NoJR5d8mo=";
    };

    nativeBuildInputs = [ python3 ];

    buildPhase = ''
      runHook preBuild
      mkdir build
      (cd src && python3 lilak.py)
      mv build/* ./
      # remove timestamp from file
      sed -i 's/^\(## *File Version[^,]*\),.*/\1/' fa-IR.aff
      runHook postBuild
    '';

    dictFileName = "fa-IR";
    readmeFile = "README.md";

    meta = {
      description = "Hunspell dictionary for Persian (Iran)";
      homepage = "https://github.com/b00f/lilak";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ nix-julia ];
      platforms = lib.platforms.all;
    };
  };

  # PERSIAN
  fa_IR = fa-ir;

  # FRENCH
  fr-any = mkDictFromDicollecte {
    dictFileName = "fr-toutesvariantes";

    longDescription = ''
      Ce dictionnaire contient les nouvelles et les anciennes graphies des
      mots concernés par la réforme de 1990.
    '';

    shortDescription = "French (any variant)";
    shortName = "fr-any";
  };

  fr-classique = mkDictFromDicollecte {
    dictFileName = "fr-classique";

    longDescription = ''
      Ce dictionnaire est une extension du dictionnaire «Moderne» et propose
      en sus des graphies alternatives, parfois encore très usitées, parfois
      tombées en désuétude.
    '';

    shortDescription = "French (classic)";
    shortName = "fr-classique";
  };

  fr-moderne = mkDictFromDicollecte {
    dictFileName = "fr-moderne";
    isDefault = true;

    longDescription = ''
      Ce dictionnaire propose une sélection des graphies classiques et
      réformées, suivant la lente évolution de l’orthographe actuelle. Ce
      dictionnaire contient les graphies les moins polémiques de la réforme.
    '';

    shortDescription = "French (modern)";
    shortName = "fr-moderne";
  };

  fr-reforme1990 = mkDictFromDicollecte {
    dictFileName = "fr-reforme1990";

    longDescription = ''
      Ce dictionnaire ne connaît que les graphies nouvelles des mots concernés
      par la réforme de 1990.
    '';

    shortDescription = "French (1990 reform)";
    shortName = "fr-reforme1990";
  };

  he-il = mkDictFromLibreOffice {
    dictFileName = "he_IL";
    license = with lib.licenses; [ agpl3Plus ];
    readmeFile = "README_he_IL.txt";
    shortDescription = "Hebrew (Israel)";
    shortName = "he-il";
  };

  # HEBREW
  he_IL = he-il;

  hr-hr = mkDictFromLibreOffice {
    dictFileName = "hr_HR";

    license = with lib.licenses; [
      gpl2Only
      lgpl21Only
      mpl11
    ];

    readmeFile = "README_hr_HR.txt";
    shortDescription = "Croatian (Croatia)";
    shortName = "hr-hr";
  };

  # CROATIAN
  hr_HR = hr-hr;

  hu-hu = mkDictFromLibreOffice {
    dictFileName = "hu_HU";

    license = with lib.licenses; [
      mpl20
      lgpl3
    ];

    shortDescription = "Hungarian (Hungary)";
    shortName = "hu-hu";
  };

  # HUNGARIAN
  hu_HU = hu-hu;
  # INDONESIA
  id_ID = id_id;

  id_id = mkDictFromLibreOffice {
    dictFileName = "id_ID";

    license = with lib.licenses; [
      lgpl21Only
      lgpl3Only
    ];

    readmeFile = "README-dict.md";
    shortDescription = "Bahasa Indonesia (Indonesia)";
    shortName = "id-id";
    sourceRoot = "id";
  };

  it-it = mkDictFromLinguistico {
    src = fetchurl {
      url = "mirror://sourceforge/linguistico/italiano_2_4_2007_09_01.zip";
      sha256 = "0m9frz75fx456bczknay5i446gdcp1smm48lc0qfwzhz0j3zcdrd";
    };

    dictFileName = "it_IT";
    shortDescription = "Hunspell dictionary for 'Italian (Italy)' from Linguistico";
    shortName = "it-it";
  };

  # ITALIAN
  it_IT = it-it;

  ko-kr = mkDict rec {
    pname = "hunspell-dict-ko-kr";
    version = "0.7.94";

    src = fetchFromGitHub {
      owner = "spellcheck-ko";
      repo = "hunspell-dict-ko";
      rev = version;
      hash = "sha256-eHuNppqB536wHXftzDghpB3cM9CNFKW1z8f0SNkEiD8=";
    };

    nativeBuildInputs = [ (python3.withPackages (ps: [ ps.pyyaml ])) ];

    preInstall = ''
      mv ko.aff ko_KR.aff
      mv ko.dic ko_KR.dic
    '';

    dictFileName = "ko_KR";
    readmeFile = "README.md";

    meta = {
      description = "Hunspell dictionary for Korean (South Korea)";
      homepage = "https://github.com/spellcheck-ko/hunspell-dict-ko";

      license = with lib.licenses; [
        gpl2Plus
        lgpl21Plus
        mpl11
      ];

      maintainers = with lib.maintainers; [ honnip ];
    };
  };

  # KOREAN
  ko_KR = ko-kr;

  nb-no = mkDictFromLibreOffice {
    dictFileName = "nb_NO";
    license = with lib.licenses; [ gpl2Only ];
    readmeFile = "README_hyph_NO.txt";
    shortDescription = "Norwegian Bokmål (Norway)";
    shortName = "nb-no";
    sourceRoot = "no";
  };

  # NORWEGIAN
  nb_NO = nb-no;
  # DUTCH
  nl_NL = nl_nl;

  nl_nl = mkDict rec {
    pname = "hunspell-dict-nl-nl";
    version = "2.20.19";

    src = fetchFromGitHub {
      owner = "OpenTaal";
      repo = "opentaal-hunspell";
      rev = version;
      sha256 = "0jma8mmrncyzd77kxliyngs4z6z4769g3nh0a7xn2pd4s5y2xdpy";
    };

    preInstall = ''
      mv nl.aff nl_NL.aff
      mv nl.dic nl_NL.dic
    '';

    dictFileName = "nl_NL";
    readmeFile = "README.md";

    meta = {
      description = "Hunspell dictionary for Dutch (Netherlands) from OpenTaal";
      homepage = "https://www.opentaal.org/";

      license = with lib.licenses; [
        bsd3 # or
        cc-by-30
      ];

      maintainers = with lib.maintainers; [ artturin ];
    };
  };

  nn-no = mkDictFromLibreOffice {
    dictFileName = "nn_NO";
    license = with lib.licenses; [ gpl2Only ];
    readmeFile = "README_hyph_NO.txt";
    shortDescription = "Norwegian Nynorsk (Norway)";
    shortName = "nn-no";
    sourceRoot = "no";
  };

  nn_NO = nn-no;

  pl-pl = mkDictFromLibreOffice {
    dictFileName = "pl_PL";

    # the README doesn't specify versions of licenses :/
    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
      mpl10
      asl20
      cc-by-sa-25
    ];

    readmeFile = "README_en.txt";
    shortDescription = "Polish (Poland)";
    shortName = "pl-pl";
  };

  # POLISH
  pl_PL = pl-pl;

  pt-br = mkDictFromLibreOffice {
    dictFileName = "pt_BR";
    license = with lib.licenses; [ lgpl3 ];
    readmeFile = "README_pt_BR.txt";
    shortDescription = "Portuguese (Brazil)";
    shortName = "pt-br";
  };

  pt-pt = mkDictFromLibreOffice {
    dictFileName = "pt_PT";

    license = with lib.licenses; [
      gpl2
      lgpl21
      mpl11
    ];

    readmeFile = "README_pt_PT.txt";
    shortDescription = "Portuguese (Portugal)";
    shortName = "pt-pt";
  };

  # PORTUGUESE
  pt_BR = pt-br;
  pt_PT = pt-pt;

  ro-ro = mkDict rec {
    pname = "hunspell-dict-ro-ro";
    version = "3.3.10";

    src = fetchurl {
      url = "mirror://sourceforge/rospell/${fileName}";
      hash = "sha256-fxKNZOoGyeZxHDCxGMCv7vsBTY8zyS2szfRVq6LQRRk=";
    };

    nativeBuildInputs = [ unzip ];
    dictFileName = "ro_RO";
    fileName = "${dictFileName}.${version}.zip";
    readmeFile = "README";
    shortDescription = "Romanian (Romania)";
    shortName = "ro-ro";

    unpackCmd = ''
      unzip $src ${dictFileName}.aff ${dictFileName}.dic ${readmeFile} -d ${dictFileName}
    '';

    meta = {
      description = "Hunspell dictionary for ${shortDescription} from rospell";
      homepage = "https://sourceforge.net/projects/rospell/";
      license = with lib.licenses; [ gpl2Only ];
      maintainers = with lib.maintainers; [ Andy3153 ];
    };
  };

  # ROMANIAN
  ro_RO = ro-ro;

  ru-ru = mkDictFromLibreOffice {
    dictFileName = "ru_RU";

    license = with lib.licenses; [
      mpl20
      lgpl3
    ];

    shortDescription = "Russian (Russian)";
    shortName = "ru-ru";
  };

  ru-ru-mozilla = mkDict {
    pname = "hunspell-dict-ru-ru-mozilla";
    version = "0-unstable-2026-05-30";

    src = fetchFromGitHub {
      owner = "Goudron";
      repo = "ru-spelling-dictionary";
      rev = "43cc600462d8681bc6e92d1afb29874e2902ea9b";
      hash = "sha256-EN/f5lbpBiyItEFcHTJbuwuJF3rghkB1f5T9G0a2tdk=";
    };

    dictFileName = "ru_RU";
    readmeFile = "README.md";

    meta = {
      description = "Hunspell dictionary for Russian, updated version as used in Mozilla products";
      homepage = "https://github.com/Goudron/ru-spelling-dictionary";
      license = [ lib.licenses.mpl20 ];
    };
  };

  # RUSSIAN
  ru_RU = ru-ru;
  ru_RU-mozilla = ru-ru-mozilla;

  sk-sk = mkDictFromLibreOffice {
    dictFileName = "sk_SK";

    license = with lib.licenses; [
      gpl2
      lgpl21
      mpl11
    ];

    readmeFile = "README_sk.txt";
    shortDescription = "Slovak (Slovakia)";
    shortName = "sk-sk";
  };

  # SLOVAK
  sk_SK = sk-sk;

  sv-fi = mkDictFromDSSO {
    dictFileName = "sv_FI";
    shortDescription = "Swedish (Finland)";
    shortName = "sv-fi";
  };

  sv-se = mkDictFromDSSO {
    dictFileName = "sv_SE";
    shortDescription = "Swedish (Sweden)";
    shortName = "sv-se";
  };

  # Finlandian Swedish (hello Linus Torvalds)
  sv_FI = sv-fi;
  # SWEDISH
  sv_SE = sv-se;

  th-th = mkDict {
    pname = "hunspell-dict-th-th";
    version = "0-unstable-2025-12-29";

    src = fetchFromGitHub {
      owner = "SyafiqHadzir";
      repo = "Hunspell-TH";
      rev = "a23b0521438f2735dc73efaee61391c6106ae196";
      sha256 = "sha256-fRHtglTVoUgeQ8v/+pBWxfk+EgZv/uAt9Ka6tK1GJgA=";
    };

    dictFileName = "th_TH";
    readmeFile = "README.md";

    meta = {
      description = "Hunspell dictionary for Central Thai (Thailand)";
      homepage = "https://github.com/SyafiqHadzir/Hunspell-TH";
      license = with lib.licenses; [ gpl3 ];
      maintainers = with lib.maintainers; [ toastal ]; # looking for a native speaker
      platforms = lib.platforms.all;
    };
  };

  # THAI
  th_TH = th-th;

  # TOKI PONA
  tok = mkDict rec {
    pname = "hunspell-dict-tok";
    version = "20220829";

    src = fetchzip {
      url = "https://github.com/somasis/hunspell-tok/releases/download/${version}/hunspell-tok-${version}.tar.gz";
      sha256 = "sha256-RiAODKXPUeIcf8IFcU6Tacehq5S8GYuPTuxEiN2CXD0=";
    };

    dictFileName = "tok";
    dontBuild = true;
    readmeFile = "README.en.adoc";

    meta = {
      description = "Hunspell dictionary for Toki Pona";
      homepage = "https://github.com/somasis/hunspell-tok";

      license = with lib.licenses; [
        cc0
        publicDomain
        cc-by-sa-30
        cc-by-sa-40
      ];

      maintainers = with lib.maintainers; [ somasis ];
      platforms = lib.platforms.all;
    };
  };

  tr-tr = mkDict {
    pname = "hunspell-dict-tr-tr";
    version = "1.1.1";

    src = fetchFromGitHub {
      owner = "tdd-ai";
      repo = "hunspell-tr";
      rev = "7302eca5f3652fe7ae3d3ec06c44697c97342b4e";
      hash = "sha256-r/I5T/1e7gcp2XZ4UvnpFmWMTsNqLZSCbkqPcgC13PE=";
    };

    dictFileName = "tr_TR";
    readmeFile = "README.md";

    meta = {
      description = "Hunspell dictionary for Turkish (Turkey) from tdd-ai";
      homepage = "https://github.com/tdd-ai/hunspell-tr/";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ samemrecebi ];
      platforms = lib.platforms.all;
    };
  };

  # Turkish
  tr_TR = tr-tr;

  uk-ua = mkDict rec {
    pname = "hunspell-dict-uk-ua";
    version = "6.5.3";

    src = fetchurl {
      url = "https://extensions.libreoffice.org/assets/downloads/521/${_version}/dict-uk_UA-${version}.oxt";
      hash = "sha256-c957WHJqaf/M2QrE2H3aIDAWGoQDnDl0na7sd+kUXNI=";
    };

    nativeBuildInputs = [ unzip ];
    _version = "1727974630";
    dictFileName = "uk_UA";
    readmeFile = "README_uk_UA.txt";

    unpackCmd = ''
      unzip $src ${dictFileName}/{${dictFileName}.dic,${dictFileName}.aff,${readmeFile}}
    '';

    meta = {
      description = "Hunspell dictionary for Ukrainian (Ukraine) from LibreOffice";
      homepage = "https://extensions.libreoffice.org/extensions/ukrainian-spelling-dictionary-and-thesaurus/";
      license = lib.licenses.mpl20;
      maintainers = with lib.maintainers; [ dywedir ];
      platforms = lib.platforms.all;
    };
  };

  # UKRAINIAN
  uk_UA = uk-ua;

  uz-uz = mkDict rec {
    pname = "hunspell-dict-uz-uz";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "uzbek-net";
      repo = "uz-hunspell";
      tag = version;
      hash = "sha256-l3Ll+mKjAndEcBX6jxTVEyHkMzuQpPDj+2kY5qtwzh8=";
    };

    dictFileName = "uz_UZ";
    readmeFile = "README.md";
    shortName = "uz-uz";

    meta = {
      description = "Hunspell dictionary for Uzbek";
      homepage = "https://github.com/uzbek-net/uz-hunspell";

      license = with lib.licenses; [
        gpl3Plus
      ];

      maintainers = with lib.maintainers; [
        orzklv
        shakhzodkudratov
        bahrom04
        bemeritus
      ];
    };
  };

  # UZBEK
  uz_UZ = uz-uz;
}
