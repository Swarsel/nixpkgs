{
  lib,
  defaultGemConfig,
  ruby,
  should,
  test,
}:
let
  testConfigs = {
    inherit lib;
    gemConfig = defaultGemConfig;
  };
  functions = (import ./functions.nix testConfigs);
in
builtins.concatLists [
  (test.run "All set, no gemdir"
    (functions.bundlerFiles {
      gemfile = test/Gemfile;
      gemset = test/gemset.nix;
      lockfile = test/Gemfile.lock;
    })
    {
      gemfile = should.equal test/Gemfile;
      gemset = should.equal test/gemset.nix;
      lockfile = should.equal test/Gemfile.lock;
    }
  )

  (test.run "Just gemdir"
    (functions.bundlerFiles {
      gemdir = test/.;
    })
    {
      gemfile = should.equal test/Gemfile;
      gemset = should.equal test/gemset.nix;
      lockfile = should.equal test/Gemfile.lock;
    }
  )

  (test.run "Gemset and dir"
    (functions.bundlerFiles {
      gemdir = test/.;
      gemset = test/extraGemset.nix;
    })
    {
      gemfile = should.equal test/Gemfile;
      gemset = should.equal test/extraGemset.nix;
      lockfile = should.equal test/Gemfile.lock;
    }
  )

  (test.run "Filter empty gemset" { } (
    set:
    functions.filterGemset {
      inherit ruby;
      groups = [ "default" ];
    } set == { }
  ))
  (
    let
      gemSet = {
        test = {
          groups = [
            "x"
            "y"
          ];
        };
      };
    in
    test.run "Filter matches a group" gemSet (
      set:
      functions.filterGemset {
        inherit ruby;

        groups = [
          "y"
          "z"
        ];
      } set == gemSet
    )
  )
  (
    let
      gemSet = {
        test = {
          platforms = [ ];
        };
      };
    in
    test.run "Filter matches empty platforms list" gemSet (
      set:
      functions.filterGemset {
        inherit ruby;
        groups = [ ];
      } set == gemSet
    )
  )
  (
    let
      gemSet = {
        test = {
          platforms = [
            {
              version = ruby.version.majMin;
              engine = ruby.rubyEngine;
            }
          ];
        };
      };
    in
    test.run "Filter matches on platform" gemSet (
      set:
      functions.filterGemset {
        inherit ruby;
        groups = [ ];
      } set == gemSet
    )
  )
  (
    let
      gemSet = {
        test = {
          groups = [
            "x"
            "y"
          ];
        };
      };
    in
    test.run "Filter excludes based on groups" gemSet (
      set:
      functions.filterGemset {
        inherit ruby;

        groups = [
          "a"
          "b"
        ];
      } set == { }
    )
  )
]
