{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bzip2,
  frog,
  gitUpdater,
  icu,
  libexttextcat,
  libfolia,
  libtar,
  libtool,
  libxml2,
  pkg-config,
  ticcutils,
  uctodata,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ucto";
  version = "0.36";

  src = fetchFromGitHub {
    owner = "LanguageMachines";
    repo = "ucto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sq1AslcpoG5gY40DiSMtphp7gXGYRuX1QrQYVGuM/+4=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    bzip2
    libtool
    autoconf-archive
    icu
    libtar
    libxml2
    libexttextcat
    ticcutils
    libfolia
    uctodata
  ];

  postInstall = ''
    # ucto expects the data files installed in the same prefix
    mkdir -p $out/share/ucto/;
    for f in ${uctodata}/share/ucto/*; do
      echo "Linking $f"
      ln -s $f $out/share/ucto/;
    done;
  '';

  passthru = {
    tests = {
      /**
        Reverse dependencies. Does not respect overrides.
      */
      reverseDependencies = lib.recurseIntoAttrs {
        inherit frog;
      };
    };

    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Rule-based tokenizer for natural language";

    longDescription = ''
      Ucto tokenizes text files: it separates words from punctuation, and splits sentences. It offers several other basic preprocessing steps such as changing case that you can all use to make your text suited for further processing such as indexing, part-of-speech tagging, or machine translation.

      Ucto comes with tokenisation rules for several languages and can be easily extended to suit other languages. It has been incorporated for tokenizing Dutch text in Frog, a Dutch morpho-syntactic processor.
    '';

    homepage = "https://languagemachines.github.io/ucto/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ roberth ];
    platforms = lib.platforms.all;
    mainProgram = "ucto";
  };

})
