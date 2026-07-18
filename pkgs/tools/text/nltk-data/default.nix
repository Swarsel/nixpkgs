{
  lib,
  fetchFromGitHub,
  newScope,
  stdenvNoCC,
  unzip,
}:
let
  base = {
    version = "0-unstable-2024-07-29";
    nativeBuildInputs = [ unzip ];
    dontBuild = true;
    dontFixup = true;

    meta = {
      description = "NLTK Data";
      homepage = "https://github.com/nltk/nltk_data";
      license = lib.licenses.asl20;

      maintainers = with lib.maintainers; [
        bengsparks
        happysalada
      ];

      platforms = lib.platforms.all;
    };
  };
  makeNltkDataPackage =
    {
      hash,
      location,
      pname,
    }:
    let
      src = fetchFromGitHub {
        inherit hash;
        owner = "nltk";
        repo = "nltk_data";
        rev = "cfe82914f3c2d24363687f1db3b05e8b9f687e2b";
        sparseCheckout = [ "packages/${location}/${pname}.zip" ];
      };
    in
    stdenvNoCC.mkDerivation (
      base
      // {
        inherit pname src;
        inherit (base) version;

        installPhase = ''
          runHook preInstall

          mkdir -p $out
          unzip ${src}/packages/${location}/${pname}.zip
          mkdir -p $out/${location}
          cp -R ${pname}/ $out/${location}

          runHook postInstall
        '';
      }
    );

  makeChunker =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-kemjqaCM9hlKAdMw8oVJnp62EAC9rMQ50dKg7wlAwEc=";
      location = "chunkers";
    };

  makeCorpus =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-8lMjW5YI8h6dHJ/83HVY2OYGDyKPpgkUAKPISiAKqqk=";
      location = "corpora";
    };

  makeGrammar =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-pyLEcX3Azv8j1kCGvVYonuiNgVJxtWt7veU0S/yNbIM=";
      location = "grammars";
    };

  makeHelp =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-97mYLNES5WujLF5gD8Ul4cJ6LqSzz+jDzclUsdBeHNE=";
      location = "help";
    };

  makeMisc =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-XtizfEsc8TYWqvvC/eSFdha2ClC5/ZiJM8nue0vXLb4=";
      location = "misc";
    };

  makeModel =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-iq3weEgCci6rgLW2j28F2eRLprJtInGXKe/awJPSVG4=";
      location = "models";
    };

  makeTagger =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-tl3Cn2okhBkUtTXvAmFRx72Brez6iTGRdmFTwFmpk3M=";
      location = "taggers";
    };

  makeTokenizer =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-OzMkruoYbFKqzuimOXIpE5lhHz8tmSqOFoLT+fjdTVg=";
      location = "tokenizers";
    };

  makeStemmer =
    pname:
    makeNltkDataPackage {
      inherit pname;
      hash = "sha256-mNefwOPVJGz9kXV3LV4DuV7FJpNir/Nwg4ujd0CogEk=";
      location = "stemmers";
    };
in
lib.makeScope newScope (self: {
  ## Corpora
  abc = makeCorpus "abc";
  alpino = makeCorpus "alpino";
  ## Taggers
  averaged-perceptron-tagger = makeTagger "averaged_perceptron_tagger";
  averaged-perceptron-tagger-eng = makeTagger "averaged_perceptron_tagger_eng";
  averaged-perceptron-tagger-ru = makeTagger "averaged_perceptron_tagger_ru";
  averaged-perceptron-tagger-rus = makeTagger "averaged_perceptron_tagger_rus";
  ## Grammars
  basque-grammars = makeGrammar "basque_grammars";
  bcp47 = makeCorpus "bcp47";
  biocreative-ppi = makeCorpus "biocreative_ppi";
  ## Models
  bllip-wsj-no-aux = makeModel "bllip_wsj_no_aux";
  book-grammars = makeGrammar "book_grammars";
  brown = makeCorpus "brown";
  brown-tei = makeCorpus "brown_tei";
  cess-cat = makeCorpus "cess_cat";
  cess-esp = makeCorpus "cess_esp";
  chat80 = makeCorpus "chat80";
  city-database = makeCorpus "city_database";
  cmudict = makeCorpus "cmudict";
  comparative-sentences = makeCorpus "comparative_sentences";
  comtrans = makeCorpus "comtrans";
  conll2000 = makeCorpus "conll2000";
  conll2002 = makeCorpus "conll2002";
  conll2007 = makeCorpus "conll2007";
  crubadan = makeCorpus "crubadan";
  dependency-treebank = makeCorpus "dependency_treebank";
  dolch = makeCorpus "dolch";
  europarl-raw = makeCorpus "europarl_raw";
  extended-omw = makeCorpus "extended_omw";
  floresta = makeCorpus "floresta";
  framenet-v15 = makeCorpus "framenet_v15";
  framenet-v17 = makeCorpus "framenet_v17";
  gazetteers = makeCorpus "gazetteers";
  genesis = makeCorpus "genesis";
  gutenberg = makeCorpus "gutenberg";
  ieer = makeCorpus "ieer";
  inaugural = makeCorpus "inaugural";
  indian = makeCorpus "indian";
  jeita = makeCorpus "jeita";
  kimmo = makeCorpus "kimmo";
  knbc = makeCorpus "knbc";
  large-grammars = makeGrammar "large_grammars";
  lin-thesaurus = makeCorpus "lin_thesaurus";
  mac-morpho = makeCorpus "mac_morpho";
  machado = makeCorpus "machado";
  masc-tagged = makeCorpus "masc_tagged";
  ## Chunkers
  maxent-ne-chunker = makeChunker "maxent_ne_chunker";
  maxent-ne-chunker-tab = makeChunker "maxent_ne_chunker_tab";
  maxent-treebank-pos-tagger = makeTagger "maxent_treebank_pos_tagger";
  maxent-treebank-pos-tagger-tab = makeTagger "maxent_treebank_pos_tagger_tab";
  moses-sample = makeModel "moses_sample";
  movie-reviews = makeCorpus "movie_reviews";
  mte-teip5 = makeCorpus "mte_teip5";
  ## Misc
  mwa-ppdb = makeMisc "mwa_ppdb";
  names = makeCorpus "names";
  nombank-1-0 = makeCorpus "nombank.1.0";
  nonbreaking-prefixes = makeCorpus "nonbreaking_prefixes";
  nps-chat = makeCorpus "nps_chat";
  omw = makeCorpus "omw";
  omw-1-4 = makeCorpus "omw-1.4";
  opinion-lexicon = makeCorpus "opinion_lexicon";
  panlex-swadesh = makeCorpus "panlex_swadesh";
  paradigms = makeCorpus "paradigms";
  pe08 = makeCorpus "pe08";
  perluniprops = makeMisc "perluniprops";
  pil = makeCorpus "pil";
  pl196x = makeCorpus "pl196x";
  ## Stemmers
  porter-test = makeStemmer "porter_test";
  ppattach = makeCorpus "ppattach";
  problem-reports = makeCorpus "problem_reports";
  product-reviews-1 = makeCorpus "product_reviews_1";
  product-reviews-2 = makeCorpus "product_reviews_2";
  propbank = makeCorpus "propbank";
  pros-cons = makeCorpus "pros_cons";
  ptb = makeCorpus "ptb";
  ## Tokenizers
  punkt = makeTokenizer "punkt";
  punkt-tab = makeTokenizer "punkt_tab";
  qc = makeCorpus "qc";
  reuters = makeCorpus "reuters";
  rslp = makeStemmer "rslp";
  rte = makeCorpus "rte";
  sample-grammars = makeGrammar "sample_grammars";
  semcor = makeCorpus "semcor";
  senseval = makeCorpus "senseval";
  sentence-polarity = makeCorpus "sentence_polarity";
  sentiwordnet = makeCorpus "sentiwordnet";
  shakespeare = makeCorpus "shakespeare";
  sinica-treebank = makeCorpus "sinica_treebank";
  smultron = makeCorpus "smultron";
  snowball-data = makeStemmer "snowball_data";
  spanish-grammars = makeGrammar "spanish_grammars";
  state-union = makeCorpus "state_union";
  stopwords = makeCorpus "stopwords";
  subjectivity = makeCorpus "subjectivity";
  swadesh = makeCorpus "swadesh";
  switchboard = makeCorpus "switchboard";
  ## Help
  tagsets-json = makeHelp "tagsets_json";
  timit = makeCorpus "timit";
  toolbox = makeCorpus "toolbox";
  treebank = makeCorpus "treebank";
  twitter-samples = makeCorpus "twitter_samples";
  udhr = makeCorpus "udhr";
  udhr2 = makeCorpus "udhr2";
  unicode-samples = makeCorpus "unicode_samples";
  universal-tagset = makeTagger "universal_tagset";
  universal-treebanks-v20 = makeCorpus "universal_treebanks_v20";
  verbnet = makeCorpus "verbnet";
  verbnet3 = makeCorpus "verbnet3";
  webtext = makeCorpus "webtext";
  wmt15-eval = makeModel "wmt15_eval";
  word2vec-sample = makeModel "word2vec_sample";
  wordnet = makeCorpus "wordnet";
  wordnet-ic = makeCorpus "wordnet_ic";
  wordnet2021 = makeCorpus "wordnet2021";
  wordnet2022 = makeCorpus "wordnet2022";
  wordnet31 = makeCorpus "wordnet31";
  words = makeCorpus "words";
  ycoe = makeCorpus "ycoe";
})
