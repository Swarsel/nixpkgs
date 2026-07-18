# hyphen dictionaries

{
  lib,
  stdenv,
  fetchgit,
  hyphen,
  symlinkJoin,
}:

let
  # this does not assume any structure for dictFilePath and readmeFilePath
  mkDictFromLibreofficeGitCustom =
    {
      dictFileName,
      dictFilePath,
      shortDescription,
      shortName,
      subdir,
      filenameAliases ? "",
      readmeFilePath ? "",
    }:
    stdenv.mkDerivation rec {
      pname = "hyphen-dict-${shortName}-libreoffice";
      version = "24.8";

      src = fetchgit {
        url = "https://anongit.freedesktop.org/git/libreoffice/dictionaries.git";
        rev = "e4ad1862342d7e1365978499ca951ae4788c9dc0";
        hash = "sha256-sv3KnmrewE1dRxeO+TqfOjfHjoJpzJ6p8MdBDiT3Ips=";
      };

      installPhase = ''
        runHook preInstall
        cd $src/${subdir}
        install -dm755 "$out/share/hyphen"
        install -m644 "${dictFilePath}" "$out/share/hyphen"
        # Aliases can be found in dictionaries.xcu.
        for lang in ${filenameAliases}; do
          ln -s "$out/share/hyphen/hyph_${dictFileName}.dic" "$out/share/hyphen/hyph_$lang.dic"
        done
        # docs
        if [ -n "${readmeFilePath}" ]; then
          install -dm755 "$out/share/doc/"
          install -m644 "${readmeFilePath}" "$out/share/doc/${pname}.txt"
        fi
        runHook postInstall
      '';

      dontBuild = true;

      meta = {
        description = "Hyphen dictionary for ${shortDescription} from LibreOffice";
        homepage = "https://wiki.documentfoundation.org/Development/Dictionaries";
        license = with lib.licenses; [ mpl20 ];
        maintainers = with lib.maintainers; [ theCapypara ];
        platforms = lib.platforms.all;
      };
    };

  # wrapper for backwards compatibility
  mkDictFromLibreofficeGit =
    {
      dictFileName,
      shortDescription,
      shortName,
      subdir,
      filenameAliases ? "",
      readmeFileName ? "",
    }:
    mkDictFromLibreofficeGitCustom {
      inherit subdir;
      inherit shortName;
      inherit shortDescription;
      dictFileName = dictFileName;
      dictFilePath = "hyph_${dictFileName}.dic";
      filenameAliases = filenameAliases;
      readmeFilePath = if (readmeFileName != "") then "README_${readmeFileName}.txt" else "";
    };

  dicts = rec {

    af-za = mkDictFromLibreofficeGit {
      dictFileName = "af_ZA";
      filenameAliases = "af_NA";
      readmeFileName = "af_ZA";
      shortDescription = "Afrikaans";
      shortName = "af-za";
      subdir = "af_ZA";
    };

    # see https://wiki.documentfoundation.org/Development/Dictionaries
    # for a list of available hyphenation dictionaries
    # see https://github.com/LibreOffice/dictionaries
    # for the sources and to find the names of the README files
    # AFRIKAANS
    af_NA = af-za;
    af_ZA = af-za;

    as-in = mkDictFromLibreofficeGit {
      dictFileName = "as_IN";
      readmeFileName = "as_IN";
      shortDescription = "Assamese";
      shortName = "as-in";
      subdir = "as_IN";
    };

    # ASSAMESE
    as_IN = as-in;

    be-by = mkDictFromLibreofficeGit {
      dictFileName = "be_BY";
      readmeFileName = "be_BY";
      shortDescription = "Belarussian";
      shortName = "be-by";
      subdir = "be_BY";
    };

    # BELARUSSIAN
    be_BY = be-by;

    bg-bg = mkDictFromLibreofficeGit {
      dictFileName = "bg_BG";
      readmeFileName = "hyph_bg_BG";
      shortDescription = "Bulgarian";
      shortName = "bg-bg";
      subdir = "bg_BG";
    };

    # BULGARIAN
    bg_BG = bg-bg;

    ca-es = mkDictFromLibreofficeGitCustom {
      dictFileName = "ca";
      dictFilePath = "dictionaries/hyph_ca.dic";
      filenameAliases = "ca_ES_valencia ca_AD ca_FR ca_IT";
      readmeFilePath = "README_hyph_ca.txt";
      shortDescription = "Catalan";
      shortName = "ca-es";
      subdir = "ca";
    };

    ca_AD = ca-es;
    ca_ES = ca-es;
    # CATALAN
    ca_ES_valencia = ca-es;
    ca_FR = ca-es;
    ca_IT = ca-es;

    cs-cz = mkDictFromLibreofficeGit {
      dictFileName = "cs_CZ";
      readmeFileName = "cs";
      shortDescription = "Czech";
      shortName = "cs-cz";
      subdir = "cs_CZ";
    };

    # CZECH
    cs_CZ = cs-cz;

    da-dk = mkDictFromLibreofficeGitCustom {
      dictFileName = "da_DK";
      dictFilePath = "hyph_da_DK.dic";
      readmeFilePath = "HYPH_da_DK_README.txt";
      shortDescription = "Danish";
      shortName = "da-dk";
      subdir = "da_DK";
    };

    # DANISH
    da_DK = da-dk;

    de-at = mkDictFromLibreofficeGit {
      dictFileName = "de_AT";
      readmeFileName = "hyph_de";
      shortDescription = "German (Austria)";
      shortName = "de-at";
      subdir = "de";
    };

    de-ch = mkDictFromLibreofficeGit {
      dictFileName = "de_CH";
      readmeFileName = "hyph_de";
      shortDescription = "German (Switzerland)";
      shortName = "de-ch";
      subdir = "de";
    };

    de-de = mkDictFromLibreofficeGit {
      dictFileName = "de_DE";
      readmeFileName = "hyph_de";
      shortDescription = "German (Germany)";
      shortName = "de-de";
      subdir = "de";
    };

    de_AT = de-at;
    de_CH = de-ch;
    # GERMAN
    de_DE = de-de;

    el-gr = mkDictFromLibreofficeGit {
      dictFileName = "el_GR";
      readmeFileName = "hyph_el_GR";
      shortDescription = "Greek";
      shortName = "el-gr";
      subdir = "el_GR";
    };

    # GREEK
    el_GR = el-gr;

    en-gb = mkDictFromLibreofficeGit {
      dictFileName = "en_GB";
      filenameAliases = "en_ZA en_NA en_ZW en_AU en_CA en_IE en_IN en_BZ en_BS en_GH en_JM en_MW en_NZ en_TT";
      readmeFileName = "hyph_en_GB";
      shortDescription = "English (Great Britain)";
      shortName = "en-gb";
      subdir = "en";
    };

    en-us = stdenv.mkDerivation {
      pname = "hyphen-dict-en-us";
      version = hyphen.version;
      src = hyphen.src;
      nativeBuildInputs = hyphen.nativeBuildInputs;

      installPhase = ''
        runHook preInstall
        make install-hyphDATA
        runHook postInstall
      '';

      meta = {
        inherit (hyphen.meta)
          homepage
          platforms
          license
          maintainers
          ;

        description = "Hyphen dictionary for English (United States)";
      };
    };

    en_AU = en-gb;
    en_BS = en-gb;
    en_BZ = en-gb;
    en_CA = en-gb;
    # ENGLISH
    en_GB = en-gb;
    en_GH = en-gb;
    en_IE = en-gb;
    en_IN = en-gb;
    en_JM = en-gb;
    en_MW = en-gb;
    en_NA = en-gb;
    en_NZ = en-gb;
    en_TT = en-gb;
    en_US = en-us;
    en_ZA = en-gb;
    en_ZW = en-gb;

    # ESPERANTO
    eo = mkDictFromLibreofficeGitCustom {
      dictFileName = "eo";
      dictFilePath = "hyph_eo.dic";
      readmeFilePath = "desc_eo.txt";
      shortDescription = "Esperanto";
      shortName = "eo";
      subdir = "eo";
    };

    es-es = mkDictFromLibreofficeGit {
      dictFileName = "es";
      filenameAliases = "es_AR es_BO es_CL es_CO es_CR es_CU es_DO es_EC es_GQ es_GT es_HN es_MX es_NI es_PA es_PE es_PH es_PR es_PY es_SV es_US es_UY es_VE";
      readmeFileName = "hyph_es";
      shortDescription = "Spanish";
      shortName = "es-es";
      subdir = "es";
    };

    # SPANISH
    es_AR = es-es;
    es_BO = es-es;
    es_CL = es-es;
    es_CO = es-es;
    es_CR = es-es;
    es_CU = es-es;
    es_DO = es-es;
    es_EC = es-es;
    es_ES = es-es;
    es_GQ = es-es;
    es_GT = es-es;
    es_HN = es-es;
    es_MX = es-es;
    es_NI = es-es;
    es_PA = es-es;
    es_PE = es-es;
    es_PH = es-es;
    es_PR = es-es;
    es_PY = es-es;
    es_SV = es-es;
    es_US = es-es;
    es_UY = es-es;
    es_VE = es-es;

    et-ee = mkDictFromLibreofficeGit {
      dictFileName = "et_EE";
      readmeFileName = "hyph_et_EE";
      shortDescription = "Estonian";
      shortName = "et-ee";
      subdir = "et_EE";
    };

    # ESTONIAN
    et_EE = et-ee;

    fr-fr = mkDictFromLibreofficeGit {
      dictFileName = "fr";
      filenameAliases = "fr_BE fr_CA fr_CH fr_LU fr_MC";
      readmeFileName = "hyph_fr";
      shortDescription = "French";
      shortName = "fr-fr";
      subdir = "fr_FR";
    };

    # FRENCH
    fr_BE = fr-fr;
    fr_CA = fr-fr;
    fr_CH = fr-fr;
    fr_FR = fr-fr;
    fr_LU = fr-fr;
    fr_MC = fr-fr;

    gl-es = mkDictFromLibreofficeGit {
      dictFileName = "gl";
      readmeFileName = "hyph-gl";
      shortDescription = "Galician";
      shortName = "gl-es";
      subdir = "gl";
    };

    # GALICIAN
    gl_ES = gl-es;

    hr-hr = mkDictFromLibreofficeGit {
      dictFileName = "hr_HR";
      readmeFileName = "hyph_hr_HR";
      shortDescription = "Croatian";
      shortName = "hr-hr";
      subdir = "hr_HR";
    };

    # CROATIAN
    hr_HR = hr-hr;

    hu-hu = mkDictFromLibreofficeGit {
      dictFileName = "hu_HU";
      readmeFileName = "hyph_hu_HU";
      shortDescription = "Hungarian";
      shortName = "hu-hu";
      subdir = "hu_HU";
    };

    # HUNGARIAN
    hu_HU = hu-hu;

    id-id = mkDictFromLibreofficeGitCustom {
      dictFileName = "id_ID";
      dictFilePath = "hyph_id_ID.dic";
      readmeFilePath = "README-dict.adoc";
      shortDescription = "Indonesian";
      shortName = "id-id";
      subdir = "id";
    };

    # INDONESIAN
    id_ID = id-id;
    # ITALIAN
    it-CH = it-it;

    it-it = mkDictFromLibreofficeGit {
      dictFileName = "it_IT";
      filenameAliases = "it_CH";
      readmeFileName = "hyph_it_IT";
      shortDescription = "Italian";
      shortName = "it-it";
      subdir = "it_IT";
    };

    it_IT = it-it;

    kn-in = mkDictFromLibreofficeGitCustom {
      dictFileName = "kn_IN";
      dictFilePath = "hyph_kn_IN.dic";
      readmeFilePath = "README-kn_IN.txt";
      shortDescription = "Kannada";
      shortName = "kn-in";
      subdir = "kn_IN";
    };

    # KANNADA
    kn_IN = kn-in;

    lt-lt = mkDictFromLibreofficeGitCustom {
      dictFileName = "lt";
      dictFilePath = "hyph_lt.dic";
      readmeFilePath = "README_hyph";
      shortDescription = "Lithuanian";
      shortName = "lt-lt";
      subdir = "lt_LT";
    };

    # LITHUANIAN
    lt_LT = lt-lt;

    lv-lv = mkDictFromLibreofficeGit {
      dictFileName = "lv_LV";
      readmeFileName = "hyph_lv_LV";
      shortDescription = "Latvian";
      shortName = "lv-lv";
      subdir = "lv_LV";
    };

    # LATVIAN
    lv_LV = lv-lv;

    mn-mn = mkDictFromLibreofficeGit {
      dictFileName = "mn_MN";
      readmeFileName = "mn_MN";
      shortDescription = "Mongolian";
      shortName = "mn-mn";
      subdir = "mn_MN";
    };

    # MONGOLIAN
    mn_MN = mn-mn;

    nb-no = mkDictFromLibreofficeGit {
      dictFileName = "nb_NO";
      readmeFileName = "hyph_NO";
      shortDescription = "Norwegian (Bokmål)";
      shortName = "nb-no";
      subdir = "no";
    };

    # NORWEGIAN
    nb_NO = nb-no;

    nl-nl = mkDictFromLibreofficeGit {
      dictFileName = "nl_NL";
      filenameAliases = "nl_BE";
      readmeFileName = "NL";
      shortDescription = "Dutch";
      shortName = "nl-nl";
      subdir = "nl_NL";
    };

    # DUTCH
    nl_BE = nl-nl;
    nl_NL = nl-nl;

    nn-no = mkDictFromLibreofficeGit {
      dictFileName = "nn_NO";
      readmeFileName = "hyph_NO";
      shortDescription = "Norwegian (Nynorsk)";
      shortName = "nn-no";
      subdir = "no";
    };

    nn_NO = nn-no;

    or-in = mkDictFromLibreofficeGit {
      dictFileName = "or_IN";
      shortDescription = "Oriya";
      shortName = "or-in";
      subdir = "or_IN";
    };

    # ORIYA
    or_IN = or-in;

    pa-in = mkDictFromLibreofficeGit {
      dictFileName = "pa_IN";
      shortDescription = "Panjabi";
      shortName = "pa-in";
      subdir = "pa_IN";
    };

    # PANJABI
    pa_IN = pa-in;

    pl-pl = mkDictFromLibreofficeGit {
      dictFileName = "pl_PL";
      readmeFileName = "pl";
      shortDescription = "Polish";
      shortName = "pl-pl";
      subdir = "pl_PL";
    };

    # POLISH
    pl_PL = pl-pl;

    pt-br = mkDictFromLibreofficeGit {
      dictFileName = "pt_BR";
      readmeFileName = "hyph_pt_BR";
      shortDescription = "Portuguese (Brazil)";
      shortName = "pt-br";
      subdir = "pt_BR";
    };

    pt-pt = mkDictFromLibreofficeGit {
      dictFileName = "pt_PT";
      readmeFileName = "hyph_pt_PT";
      shortDescription = "Portuguese (Portugal)";
      shortName = "pt-pt";
      subdir = "pt_PT";
    };

    # PORTUGUESE
    pt_BR = pt-br;
    pt_PT = pt-pt;

    ro-ro = mkDictFromLibreofficeGit {
      dictFileName = "ro_RO";
      readmeFileName = "RO";
      shortDescription = "Romanian";
      shortName = "ro-ro";
      subdir = "ro";
    };

    # ROMANIAN
    ro_RO = ro-ro;

    ru-ru = mkDictFromLibreofficeGit {
      dictFileName = "ru_RU";
      readmeFileName = "ru_RU";
      shortDescription = "Russian (Russia)";
      shortName = "ru-ru";
      subdir = "ru_RU";
    };

    # RUSSIAN
    ru_RU = ru-ru;

    sa-in = mkDictFromLibreofficeGit {
      dictFileName = "sa_IN";
      shortDescription = "Sanskrit (India)";
      shortName = "sa-in";
      subdir = "sa_IN";
    };

    # SANSKRIT
    sa_IN = sa-in;

    sk-sk = mkDictFromLibreofficeGit {
      dictFileName = "sk_SK";
      readmeFileName = "sk";
      shortDescription = "Slovak";
      shortName = "sk-sk";
      subdir = "sk_SK";
    };

    # SLOVAK
    sk_SK = sk-sk;

    sl-si = mkDictFromLibreofficeGit {
      dictFileName = "sl_SI";
      readmeFileName = "hyph_sl_SI";
      shortDescription = "Slovenian";
      shortName = "sl-si";
      subdir = "sl_SI";
    };

    # SLOVENIAN
    sl_SI = sl-si;

    sq-al = mkDictFromLibreofficeGit {
      dictFileName = "sq_AL";
      readmeFileName = "hyph_sq_AL";
      shortDescription = "Albanian";
      shortName = "sq-al";
      subdir = "sq_AL";
    };

    # ALBANIAN
    sq_AL = sq-al;

    sr-sr = mkDictFromLibreofficeGitCustom {
      dictFileName = "sr";
      dictFilePath = "hyph_sr.dic";
      readmeFilePath = "README.txt";
      shortDescription = "Serbian (Cyrillic)";
      shortName = "sr-sr";
      subdir = "sr";
    };

    sr-sr-latn = mkDictFromLibreofficeGitCustom {
      dictFileName = "sr-Latn";
      dictFilePath = "hyph_sr-Latn.dic";
      readmeFilePath = "README.txt";
      shortDescription = "Serbian (Latin)";
      shortName = "sr-sr-latn";
      subdir = "sr";
    };

    # SERBIAN
    sr_SR = sr-sr;
    sr_SR_LATN = sr-sr-latn;

    sv-se = mkDictFromLibreofficeGit {
      dictFileName = "sv";
      readmeFileName = "hyph_sv";
      shortDescription = "Swedish";
      shortName = "sv-se";
      subdir = "sv_SE";
    };

    # SWEDISH
    sv_FI = sv-se;
    sv_SE = sv-se;

    te-in = mkDictFromLibreofficeGit {
      dictFileName = "te_IN";
      readmeFileName = "hyph_te_IN";
      shortDescription = "Telugu";
      shortName = "te-in";
      subdir = "te_IN";
    };

    # TELUGU
    te_IN = te-in;

    th-th = mkDictFromLibreofficeGit {
      dictFileName = "th_TH";
      readmeFileName = "hyph_th_TH";
      shortDescription = "Thai";
      shortName = "th-th";
      subdir = "th_TH";
    };

    # THAI
    th_TH = th-th;

    uk-ua = mkDictFromLibreofficeGit {
      dictFileName = "uk_UA";
      readmeFileName = "hyph_uk_UA";
      shortDescription = "Ukrainian";
      shortName = "uk-ua";
      subdir = "uk_UA";
    };

    # UKRAINIAN
    uk_UA = uk-ua;

    zu-za = mkDictFromLibreofficeGitCustom {
      dictFileName = "zu_ZA";
      dictFilePath = "hyph_zu_ZA.dic";
      shortDescription = "Zulu";
      shortName = "zu-za";
      subdir = "zu_ZA";
      # no readme file provided, leave empty
    };

    # ZULU
    zu_ZA = zu-za;

  };

in
dicts
// {
  all = symlinkJoin {
    name = "hyphen-all";
    paths = lib.unique (lib.attrValues dicts);
  };
}
