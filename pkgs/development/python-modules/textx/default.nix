{
  lib,
  fetchFromGitHub,
  arpeggio,
  buildPythonPackage,
  callPackage,
  click,
  flit-core,
  python,
}:

let
  textx = buildPythonPackage rec {
    pname = "textx";
    version = "4.4.0";

    src = fetchFromGitHub {
      owner = "textx";
      repo = "textx";
      tag = version;
      hash = "sha256-bwwINUJiMG6Isi0/p1DsIzzlSa0y7xR4Q6OnpKy894s=";
    };

    outputs = [
      "out"
      "testout"
    ];

    # Circular dependencies, do tests in passthru.tests instead.
    doCheck = false;

    postInstall = ''
      # FileNotFoundError: [Errno 2] No such file or directory: '$out/lib/python3.10/site-packages/textx/textx.tx
      cp "$src/textx/textx.tx" "$out/${python.sitePackages}/textx/"

      # Install tests as the tests output.
      mkdir $testout
      cp -r tests $testout/tests
    '';

    build-system = [ flit-core ];
    dependencies = [ arpeggio ];
    pyproject = true;
    pythonImportsCheck = [ "textx" ];

    passthru.tests = {
      textxTests = callPackage ./tests.nix {
        inherit
          textx-data-dsl
          textx-example-project
          textx-flow-codegen
          textx-flow-dsl
          textx-types-dsl
          ;
      };
    };

    meta = {
      description = "Domain-specific languages and parsers in Python";
      homepage = "https://github.com/textx/textx/";
      changelog = "https://github.com/textX/textX/blob/${src.tag}/CHANGELOG.md";
      license = lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "textx";
    };
  };

  textx-data-dsl = buildPythonPackage rec {
    inherit (textx) src;
    pname = "textx-data-dsl";
    version = "1.0.0";
    build-system = [ flit-core ];

    dependencies = [
      textx
      textx-types-dsl
    ];

    pathToSourceRoot = "tests/functional/registration/projects/data_dsl";
    pyproject = true;
    sourceRoot = "${src.name}/" + pathToSourceRoot;

    meta = {
      inherit (textx.meta) license maintainers;
      description = "Sample textX language for testing";
      homepage = textx.meta.homepage + "tree/${version}/" + pathToSourceRoot;
    };
  };

  textx-flow-codegen = buildPythonPackage rec {
    inherit (textx) src;
    pname = "textx-flow-codegen";
    version = "1.0.0";
    build-system = [ flit-core ];

    dependencies = [
      textx
      click
    ];

    pathToSourceRoot = "tests/functional/registration/projects/flow_codegen";
    pyproject = true;
    sourceRoot = "${src.name}/" + pathToSourceRoot;

    meta = {
      inherit (textx.meta) license maintainers;
      description = "Sample textX language for testing";
      homepage = textx.meta.homepage + "tree/${version}/" + pathToSourceRoot;
    };
  };

  textx-flow-dsl = buildPythonPackage rec {
    inherit (textx) src;
    pname = "textx-flow-dsl";
    version = "1.0.0";
    build-system = [ flit-core ];
    dependencies = [ textx ];
    pathToSourceRoot = "tests/functional/registration/projects/flow_dsl";
    pyproject = true;
    sourceRoot = "${src.name}/" + pathToSourceRoot;

    meta = {
      inherit (textx.meta) license maintainers;
      description = "Sample textX language for testing";
      homepage = textx.meta.homepage + "tree/${version}/" + pathToSourceRoot;
    };
  };

  textx-types-dsl = buildPythonPackage rec {
    inherit (textx) src;
    pname = "textx-types-dsl";
    version = "1.0.0";
    build-system = [ flit-core ];
    dependencies = [ textx ];
    pathToSourceRoot = "tests/functional/registration/projects/types_dsl";
    pyproject = true;
    sourceRoot = "${src.name}/" + pathToSourceRoot;

    meta = {
      inherit (textx.meta) license maintainers;
      description = "Sample textX language for testing";
      homepage = textx.meta.homepage + "tree/${version}/" + pathToSourceRoot;
    };
  };

  textx-example-project = buildPythonPackage rec {
    inherit (textx) src;
    pname = "textx-example-project";
    version = "1.0.0";
    build-system = [ flit-core ];
    dependencies = [ textx ];
    pathToSourceRoot = "tests/functional/subcommands/example_project";
    pyproject = true;
    sourceRoot = "${src.name}/" + pathToSourceRoot;

    meta = {
      inherit (textx.meta) license maintainers;
      description = "Sample textX sub-command for testing";
      homepage = textx.meta.homepage + "tree/${version}/" + pathToSourceRoot;
    };
  };
in
textx
