{
  lib,
  stdenv,
  libfaketime,
  python3,
  wordnet,
  writeScript,
}:

stdenv.mkDerivation rec {
  pname = "dict-db-wordnet";
  version = "542";

  buildInputs = [
    python3
    wordnet
    libfaketime
  ];

  builder = writeScript "builder.sh" ''
    . ${stdenv}/setup
    mkdir -p $out/share/dictd/
    cd $out/share/dictd

    for i in ${wordnet}/dict/data.*; do
      DATA="$DATA `echo $i | sed -e s,data,index,` $i";
    done

    source_date=$(date --utc --date=@$SOURCE_DATE_EPOCH "+%F %T")
    faketime -f "$source_date" python ${convert} $DATA
    echo en_US.UTF-8 > locale
  '';

  convert = ./wordnet_structures.py;

  meta = {
    description = "Dictd-compatible version of WordNet";

    longDescription = ''
      WordNet® is a large lexical database of English. This package makes
      the wordnet data available to dictd and by extension for lookup with
      the dict command.
    '';

    homepage = "https://wordnet.princeton.edu/";
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
