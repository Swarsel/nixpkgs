{
  lib,
  nixfmt,
  runCommand,
  runCommandLocal,
  testers,
  treefmt,
}:
let
  inherit (treefmt) buildConfig withConfig;

  testEqualContents =
    args:
    testers.testEqualContents (
      args
      // lib.optionalAttrs (builtins.isString args.expected) {
        expected = builtins.toFile "expected" args.expected;
      }
    );

  nixfmtExampleConfig = {
    formatter.nixfmt = {
      command = "nixfmt";
      includes = [ "*.nix" ];
    };

    on-unmatched = "info";
    tree-root-file = ".git/index";
  };

  nixfmtExamplePackage = withConfig {
    runtimeInputs = [ nixfmt ];
    settings = nixfmtExampleConfig;
  };

  wellFormattedTree = runCommandLocal "well-formatted-project" { } ''
    mkdir "$out"
    cat > "$out/file.nix" <<EOF
    {
      foo = "bar";
      attrs = { };
      list = [ ];
    }
    EOF
  '';

  unformattedTree = runCommandLocal "unformatted-project" { } ''
    mkdir "$out"
    cat > "$out/file.nix" <<EOF
    {
      foo="bar";
      attrs={};
      list=[];
    }
    EOF
  '';
in
{
  buildConfigEmpty = testEqualContents {
    actual = buildConfig { };
    assertion = "`buildConfig { }` builds an empty config file";
    expected = "";
  };

  buildConfigExample = testEqualContents {
    actual = buildConfig nixfmtExampleConfig;
    assertion = "`buildConfig` builds the example config";

    expected = ''
      on-unmatched = "info"
      tree-root-file = ".git/index"

      [formatter.nixfmt]
      command = "nixfmt"
      includes = ["*.nix"]
    '';
  };

  buildConfigModules = testEqualContents {
    actual = buildConfig [
      nixfmtExampleConfig
      { tree-root-file = lib.mkForce "overridden"; }
    ];

    assertion = "`buildConfig` evaluates modules to build a config";

    expected = ''
      on-unmatched = "info"
      tree-root-file = "overridden"

      [formatter.nixfmt]
      command = "nixfmt"
      includes = ["*.nix"]
    '';
  };

  nixfmtExampleCheckFails = testers.testBuildFailure' {
    drv = nixfmtExamplePackage.check unformattedTree;
    expectedBuilderExitCode = 1;

    expectedBuilderLogEntries = [
      "diff --git a/file.nix b/file.nix"
      "-  foo=\"bar\";"
      "+  foo = \"bar\";"
      "-  attrs={};"
      "+  attrs = { };"
      "-  list=[];"
      "+  list = [ ];"
    ];
  };

  nixfmtExampleCheckPasses = nixfmtExamplePackage.check wellFormattedTree;

  runNixfmtExample =
    runCommand "run-nixfmt-example"
      {
        nativeBuildInputs = [ nixfmtExamplePackage ];
        __structuredAttrs = true;

        expected = ''
          {
            foo = "bar";
            attrs = { };
            list = [ ];
          }
        '';

        input = ''
          {
            foo="bar";
            attrs={};
            list=[];
          }
        '';
      }
      ''
        export XDG_CACHE_HOME=$(mktemp -d)
        # The example config assumes the tree root has a .git/index file
        mkdir .git && touch .git/index

        # Create the input file, then format it using the wrapped treefmt
        printf "%s" "$input" > input.nix
        treefmt

        # Assert that input.nix now matches expected
        if diff -u <(printf "%s" "$expected") input.nix; then
          touch $out
        else
          echo
          echo "treefmt did not format input.nix as expected"
          exit 1
        fi
      '';
}
