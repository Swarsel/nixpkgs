{
  lib,
  stdenv,
  fetchurl,
  callPackage,
}:

let
  # Probably a bug in some FreeDict release files, but easier to trivially
  # work around than report. Not that it can cause any other problems..
  makeDictdDBFreedict =
    src: name: locale:
    makeDictdDB src name "{.,bin}" locale;

  makeDictdDB =
    src: _name: _subdir: _locale:
    stdenv.mkDerivation {
      inherit src;

      installPhase = ''
        mkdir -p $out/share/dictd
        cp $(ls ./${_subdir}/*.{dict*,index} || true) $out/share/dictd
        echo "${_locale}" >$out/share/dictd/locale
      '';

      dbName = _name;
      dontBuild = true;
      locale = _locale;
      name = "dictd-db-${_name}";

      unpackPhase = ''
        tar xf  ${src}
      '';

      meta = {
        description = "Dictd-db dictionary for dictd";
        platforms = lib.platforms.linux;
      };
    };
in
rec {
  deu2eng = makeDictdDBFreedict (fetchurl {
    sha256 = "0dqrhv04g4f5s84nbgisgcfwk5x0rpincif0yfhfh4sc1bsvzsrb";
    url = "mirror://sourceforge/freedict/deu-eng.tar.gz";
  }) "deu-eng" "de_DE";

  eng2deu = makeDictdDBFreedict (fetchurl {
    sha256 = "01x12p72sa3071iff3jhzga8588440f07zr56r3x98bspvdlz73r";
    url = "mirror://sourceforge/freedict/eng-deu.tar.gz";
  }) "eng-deu" "en_EN";

  eng2fra = makeDictdDBFreedict (fetchurl {
    sha256 = "0fi6rrnbqnhc6lq8d0nmn30zdqkibrah0mxfg27hsn9z7alwbj3m";
    url = "mirror://sourceforge/freedict/eng-fra.tar.gz";
  }) "eng-fra" "en_UK";

  eng2jpn = makeDictdDB (fetchurl {
    sha256 = "sha256-kfRT2kgbV3XKarCr4mqDRT5A1jR8M8APky5M5MFYatE=";

    url =
      let
        version = "2022.04.06";
      in
      "https://download.freedict.org/dictionaries/eng-jpn/${version}/freedict-eng-jpn-${version}.dictd.tar.xz";
  }) "eng-jpn" "eng-jpn" "en_UK";

  eng2nld = makeDictdDBFreedict (fetchurl {
    sha256 = "0rcg28ldykv0w2mpxc6g4rqmfs33q7pbvf68ssy1q9gpf6mz7vcl";
    url = "mirror://sourceforge/freedict/eng-nld.tar.gz";
  }) "eng-nld" "en_UK";

  eng2rus = makeDictdDBFreedict (fetchurl {
    sha256 = "15409ivhww1wsfjr05083pv6mg10bak8v5pg1wkiqybk7ck61rry";
    url = "mirror://sourceforge/freedict/eng-rus.tar.gz";
  }) "eng-rus" "en_UK";

  epo2eng = makeDictdDB (fetchurl {
    sha256 = "095xwqfc43dnm0g74i83lg03542f064jy2xbn3qnjxiwysz9ksnz";
    url = "https://download.freedict.org/dictionaries/epo-eng/1.0.1/freedict-epo-eng-1.0.1.dictd.tar.xz";
  }) "epo-eng" "epo-eng" "eo";

  fra2eng = makeDictdDBFreedict (fetchurl {
    sha256 = "0sdd88s2zs5whiwdf3hd0s4pzzv75sdsccsrm1wxc87l3hjm85z3";
    url = "mirror://sourceforge/freedict/fra-eng.tar.gz";
  }) "fra-eng" "fr_FR";

  jpn2eng = makeDictdDB (fetchurl {
    sha256 = "sha256-juJBoEq7EztLZzOomc7uoZhXVaQPKoUvIxxPLB0xByc=";

    url =
      let
        version = "0.1";
      in
      "mirror://sourceforge/freedict/jpn-eng/${version}/freedict-jpn-eng-${version}.dictd.tar.xz";
  }) "jpn-eng" "jpn-eng" "ja_JP";

  mueller_eng2rus_pkg = makeDictdDB (fetchurl {
    sha256 = "04r5xxznvmcb8hkxqbjgfh2gxvbdd87jnhqn5gmgvxxw53zpwfmq";
    url = "mirror://sourceforge/mueller-dict/mueller-dict-3.1.tar.gz";
  }) "mueller-eng-rus" "mueller-dict-*/dict" "en_UK";

  mueller_enru_abbr = {
    dbName = "mueller-abbr";
    locale = "en_UK";
    name = "mueller-abbr";
    outPath = "${mueller_eng2rus_pkg}/share/dictd/mueller-abbrev";
  };

  mueller_enru_base = {
    dbName = "mueller-base";
    locale = "en_UK";
    name = "mueller-base";
    outPath = "${mueller_eng2rus_pkg}/share/dictd/mueller-base";
  };

  mueller_enru_dict = {
    dbName = "mueller-dict";
    locale = "en_UK";
    name = "mueller-dict";
    outPath = "${mueller_eng2rus_pkg}/share/dictd/mueller-dict";
  };

  mueller_enru_geo = {
    dbName = "mueller-geo";
    locale = "en_UK";
    name = "mueller-geo";
    outPath = "${mueller_eng2rus_pkg}/share/dictd/mueller-geo";
  };

  mueller_enru_names = {
    dbName = "mueller-names";
    locale = "en_UK";
    name = "mueller-names";
    outPath = "${mueller_eng2rus_pkg}/share/dictd/mueller-names";
  };

  nld2eng = makeDictdDBFreedict (fetchurl {
    sha256 = "1vhw81pphb64fzsjvpzsnnyr34ka2fxizfwilnxyjcmpn9360h07";
    url = "mirror://sourceforge/freedict/nld-eng.tar.gz";
  }) "nld-eng" "nl_NL";

  wiktionary = callPackage ./wiktionary { };
  wordnet = callPackage ./dictd-wordnet.nix { };
}
