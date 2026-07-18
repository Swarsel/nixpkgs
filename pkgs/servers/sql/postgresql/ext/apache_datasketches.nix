{
  lib,
  fetchFromGitHub,
  boost186,
  fetchpatch,
  postgresql,
  postgresqlBuildExtension,
  postgresqlTestExtension,
}:

let
  version = "1.7.0";

  main_src = fetchFromGitHub {
    hash = "sha256-W41uAs3W4V7c9O/wBw3rut65bcmY8EdQS1/tPszMGqA=";
    name = "datasketches-postgresql";
    owner = "apache";
    repo = "datasketches-postgresql";
    tag = version;
  };

  cpp_src = fetchFromGitHub {
    hash = "sha256-h4+cln01jqLV0EpIqScpCyw8jxZgoVtdfBEjdvyUuVk=";
    name = "datasketches-cpp";
    owner = "apache";
    repo = "datasketches-cpp";
    tag = "5.2.0";
  };
in

postgresqlBuildExtension (finalAttrs: {
  inherit version;
  pname = "apache_datasketches";

  patches = [
    # https://github.com/apache/datasketches-cpp/pull/500
    (fetchpatch {
      extraPrefix = "datasketches-cpp/";
      hash = "sha256-6SYKy3NycYABnUCuLUXQz+mTx4VaeWMlHnJ6aM+sNt4=";
      stripLen = 1;
      url = "https://github.com/apache/datasketches-cpp/commit/639134f6e88483bd1bfca451cf09d243ade9bdd4.patch";
    })
  ];

  # fails to build with boost 1.87
  buildInputs = [ boost186 ];
  enableUpdateScript = false;

  prePatch = ''
    cp --no-preserve=mode -r ../${cpp_src.name} .
  '';

  sourceRoot = main_src.name;

  srcs = [
    main_src
    cpp_src
  ];

  passthru.tests.extension = postgresqlTestExtension {
    inherit (finalAttrs) finalPackage;

    sql = ''
      CREATE EXTENSION datasketches;
      SELECT hll_sketch_to_string(hll_sketch_build(1));
    '';
  };

  meta = {
    description = "PostgreSQL extension providing approximate algorithms for distinct item counts, quantile estimation and frequent items detection";

    longDescription = ''
      apache_datasketches is an extension to support approximate algorithms on PostgreSQL. The implementation
      is based on the Apache Datasketches CPP library, and provides support for HyperLogLog,
      Compressed Probabilistic Counting, KLL, Frequent strings, and Theta sketches.
    '';

    homepage = "https://datasketches.apache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mmusnjak ];
    platforms = postgresql.meta.platforms;
  };
})
