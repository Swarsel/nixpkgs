{
  lib,
  akkuPackages,
  guile-lib,
  haskellPackages,
  katex,
  perlPackages,
  python3Packages,
  runCommand,
  testers,
  writeText,
  writers,
}:

# If you are reading this, you can test these writers by running: nix-build . -A tests.writers

let
  inherit (lib) getExe recurseIntoAttrs;

  inherit (writers)
    makeFSharpWriter
    writeBash
    writeBashBin
    writeBabashka
    writeBabashkaBin
    writeDash
    writeDashBin
    writeFish
    writeFishBin
    writeFSharp
    writeGuile
    writeGuileBin
    writeHaskell
    writeHaskellBin
    writeJS
    writeJSBin
    writeJSON
    writeLua
    writeNim
    writeNimBin
    writeNu
    writePerl
    writePerlBin
    writePyPy3
    writePython3
    writePython3Bin
    writeRuby
    writeRust
    writeRustBin
    writeText
    writeTOML
    writeYAML
    ;

  expectSuccess =
    test:
    runCommand "run-${test.name}" { } ''
      if [[ "$(${test})" != success ]]; then
        echo 'test ${test.name} failed'
        exit 1
      fi

      touch $out
    '';

  expectSuccessBin =
    test:
    runCommand "run-${test.name}" { } ''
      if [[ "$(${getExe test})" != success ]]; then
        echo 'test ${test.name} failed'
        exit 1
      fi

      touch $out
    '';

  expectDataEqual =
    { expected, file }:
    let
      expectedFile = writeText "${file.name}-expected" expected;
    in
    testers.testEqualContents {
      actual = file;
      assertion = "${file.name} matches";
      expected = expectedFile;
    };
in
recurseIntoAttrs {
  bin = recurseIntoAttrs {
    babashka = expectSuccessBin (
      writeBabashkaBin "test-writers-babashka-bin" { } ''
        (println "success")
      ''
    );

    bash = expectSuccessBin (
      writeBashBin "test-writers-bash-bin" ''
        if [[ "test" == "test" ]]; then echo "success"; fi
      ''
    );

    dash = expectSuccessBin (
      writeDashBin "test-writers-dash-bin" ''
        test '~' = '~' && echo 'success'
      ''
    );

    fish = expectSuccessBin (
      writeFishBin "test-writers-fish-bin" ''
        if test "test" = "test"
          echo "success"
        end
      ''
    );

    guile = expectSuccessBin (
      writeGuileBin "test-writers-guile-bin" { } ''
        (display "success\n")
      ''
    );

    haskell = expectSuccessBin (
      writeHaskellBin "test-writers-haskell-bin" { libraries = [ haskellPackages.acme-default ]; } ''
        import Data.Default

        int :: Int
        int = def

        main :: IO ()
        main = case int of
          18871 -> putStrLn $ id "success"
          _ -> print "fail"
      ''
    );

    js = expectSuccessBin (
      writeJSBin "test-writers-js-bin" { libraries = [ katex ]; } ''
        var katex = require('katex');

        var html = katex.renderToString("c = \\pm\\sqrt{a^2 + b^2}");
        if (html instanceof katex.ParseError) {
          console.log("fail")
        } else {
          console.log("success")
        }
      ''
    );

    nim = expectSuccessBin (
      writeNimBin "test-writers-nim-bin" { } ''
        echo "success"
      ''
    );

    perl = expectSuccessBin (
      writePerlBin "test-writers-perl-bin" { libraries = [ perlPackages.boolean ]; } ''
        use boolean;
        print "success\n" if true;
      ''
    );

    python3 = expectSuccessBin (
      writePython3Bin "test-writers-python3-bin" { libraries = [ python3Packages.pyyaml ]; } ''
        import yaml

        y = yaml.safe_load("""
          - test: success
        """)
        print(y[0]['test'])
      ''
    );

    rust = expectSuccessBin (
      writeRustBin "test-writers-rust-bin" { } ''
        fn main(){
          println!("success")
        }
      ''
    );
    # Commented out because of this issue: https://github.com/NixOS/nixpkgs/issues/39356
    #pypy2 = expectSuccessBin (writePyPy2Bin "test-writers-pypy2-bin" { libraries = [ pypy2Packages.enum ]; } ''
    #  from enum import Enum
    #
    #  class Test(Enum):
    #      a = "success"
    #
    #  print Test.a
    #'');
    #pypy3 = expectSuccessBin (writePyPy3Bin "test-writers-pypy3-bin" { libraries = [ pypy3Packages.pyyaml ]; } ''
    #  import yaml
    #
    #  y = yaml.safe_load("""
    #    - test: success
    #  """)
    #  print(y[0]['test'])
    #'');
    # Could not test this because of external package issues :(
    #lua = writeLuaBin "test-writers-lua-bin" { libraries = [ pkgs.luaPackages.say ]; } ''
    #  s = require("say")
    #  s:set_namespace("en")
    #  s:set('money', 'I have %s dollars')
    #  s:set('wow', 'So much money!')
    #  print(s('money', {1000})) -- I have 1000 dollars
    #  s:set_namespace("fr") -- switch to french!
    #  s:set('wow', "Tant d'argent!")
    #  print(s('wow')) -- Tant d'argent!
    #  s:set_namespace("en")  -- switch back to english!
    #  print(s('wow')) -- So much money!
    #'';
    #ruby = expectSuccessBin (writeRubyBin "test-writers-ruby-bin" { libraries = [ rubyPackages.rubocop ]; } ''
    #puts "This should work!"
    #'');
  };

  data = recurseIntoAttrs {
    json = expectDataEqual {
      expected = ''
        {
          "hello": "world"
        }
      '';

      file = writeJSON "data.json" { hello = "world"; };
    };

    toml = expectDataEqual {
      expected = ''
        hello = "world"
      '';

      file = writeTOML "data.toml" { hello = "world"; };
    };

    yaml = expectDataEqual {
      expected = "hello: world\n";
      file = writeYAML "data.yaml" { hello = "world"; };
    };
  };

  path = recurseIntoAttrs {
    bash = expectSuccess (
      writeBash "test-writers-bash-path" (
        writeText "test" ''
          if [[ "test" == "test" ]]; then echo "success"; fi
        ''
      )
    );

    haskell = expectSuccess (
      writeHaskell "test-writers-haskell-path" { libraries = [ haskellPackages.acme-default ]; } (
        writeText "test" ''
          import Data.Default

          int :: Int
          int = def

          main :: IO ()
          main = case int of
            18871 -> putStrLn $ id "success"
            _ -> print "fail"
        ''
      )
    );
  };

  simple = recurseIntoAttrs {
    babashka = expectSuccess (
      writeBabashka "test-writers-babashka" { } ''
        (println "success")
      ''
    );

    bash = expectSuccess (
      writeBash "test-writers-bash" ''
        if [[ "test" == "test" ]]; then echo "success"; fi
      ''
    );

    dash = expectSuccess (
      writeDash "test-writers-dash" ''
        test '~' = '~' && echo 'success'
      ''
    );

    fish = expectSuccess (
      writeFish "test-writers-fish" ''
        if test "test" = "test"
          echo "success"
        end
      ''
    );

    fsharpNoNugetDeps = expectSuccess (
      writeFSharp "test-writers-fsharp-no-nuget-deps" ''
        printfn "success"
      ''
    );

    guile = expectSuccess (
      writeGuile "test-writers-guile"
        {
          libraries = [ guile-lib ];
          srfi = [ 1 ];
        }
        ''
          (use-modules (unit-test))
          (assert-true (= (second '(1 2 3))
                       2))
          (display "success\n")
        ''
    );

    guileR6RS = expectSuccess (
      writeGuile "test-writers-guile-r6rs"
        {
          libraries = with akkuPackages; [ r6rs-slice ];
          r6rs = true;
        }
        ''
          (import (rnrs base (6))
                  (rnrs io simple (6))
                  (slice))
          (assert (equal? (slice '(1 2 3) 0 2)
                          '(1 2)))
          (display "success\n")
        ''
    );

    guileR7RS = expectSuccess (
      writeGuile "test-writers-guile-r7rs"
        {
          r7rs = true;
        }
        ''
          (import (scheme write)
                  (srfi 1))
          (unless (= (second '(1 2 3))
                     2)
                  (error "The value should be 2."))
          (display "success\n")
        ''
    );

    haskell = expectSuccess (
      writeHaskell "test-writers-haskell" { libraries = [ haskellPackages.acme-default ]; } ''
        import Data.Default

        int :: Int
        int = def

        main :: IO ()
        main = case int of
          18871 -> putStrLn $ id "success"
          _ -> print "fail"
      ''
    );

    js = expectSuccess (
      writeJS "test-writers-js" { libraries = [ katex ]; } ''
        var katex = require('katex');

        var html = katex.renderToString("c = \\pm\\sqrt{a^2 + b^2}");
        if (html instanceof katex.ParseError) {
          console.log("fail")
        } else {
          console.log("success")
        }
      ''
    );

    luaNoLibs = expectSuccess (
      writeLua "test-writers-lua-no-libs" { } ''
        print("success")
      ''
    );

    nim = expectSuccess (
      writeNim "test-writers-nim" { } ''
        echo "success"
      ''
    );

    nu = expectSuccess (
      writeNu "test-writers-nushell" ''
        echo "success"
      ''
    );

    perl = expectSuccess (
      writePerl "test-writers-perl" { libraries = [ perlPackages.boolean ]; } ''
        use boolean;
        print "success\n" if true;
      ''
    );

    pypy3NoLibs = expectSuccess (
      writePyPy3 "test-writers-pypy3-no-libs" { } ''
        print("success")
      ''
    );

    python3 = expectSuccess (
      writePython3 "test-writers-python3" { libraries = [ python3Packages.pyyaml ]; } ''
        import yaml

        y = yaml.safe_load("""
          - test: success
        """)
        print(y[0]['test'])
      ''
    );

    # Commented out because of this issue: https://github.com/NixOS/nixpkgs/issues/39356
    #pypy2 = expectSuccessBin (writePyPy2Bin "test-writers-pypy2-bin" { libraries = [ pypy2Packages.enum ]; } ''
    #  from enum import Enum
    #
    #  class Test(Enum):
    #      a = "success"
    #
    #  print Test.a
    #'');
    #pypy3 = expectSuccessBin (writePyPy3Bin "test-writers-pypy3-bin" { libraries = [ pypy3Packages.pyyaml ]; } ''
    #  import yaml
    #
    #  y = yaml.safe_load("""
    #    - test: success
    #  """)
    #  print(y[0]['test'])
    #'');
    # Commented out because fails with 'error FS0039: The value or constructor 'JsonFSharpConverter' is not defined.'
    # fsharp = expectSuccess (makeFSharpWriter {
    #   libraries = { fetchNuGet }: [
    #     (fetchNuGet { pname = "FSharp.SystemTextJson"; version = "0.17.4"; sha256 = "1bplzc9ybdqspii4q28l8gmfvzpkmgq5l1hlsiyg2h46w881lwg2"; })
    #     (fetchNuGet { pname = "System.Text.Json"; version = "4.6.0"; sha256 = "0ism236hwi0k6axssfq58s1d8lihplwiz058pdvl8al71hagri39"; })
    #   ];
    # } "test-writers-fsharp" ''
    #
    #   #r "nuget: FSharp.SystemTextJson, 0.17.4"
    #
    #   module Json =
    #       open System.Text.Json
    #       open System.Text.Json.Serialization
    #       let options = JsonSerializerOptions()
    #       options.Converters.Add(JsonFSharpConverter())
    #       let serialize<'a> (o: 'a) = JsonSerializer.Serialize<'a>(o, options)
    #       let deserialize<'a> (str: string) = JsonSerializer.Deserialize<'a>(str, options)
    #
    #   type Letter = A | B
    #   let a = {| Hello = Some "World"; Letter = A |}
    #   if a |> Json.serialize |> Json.deserialize |> (=) a
    #   then "success"
    #   else "failed"
    #   |> printfn "%s"
    # '');
    #pypy2NoLibs = expectSuccess (writePyPy2 "test-writers-pypy2-no-libs" {} ''
    #  print("success")
    #'');
    python3NoLibs = expectSuccess (
      writePython3 "test-writers-python3-no-libs" { } ''
        print("success")
      ''
    );

    rubyNoLibs = expectSuccess (
      writeRuby "test-writers-ruby-no-libs" { } ''
        puts "success"
      ''
    );
  };

  wrapping = recurseIntoAttrs {
    babashka = expectSuccess (
      writeBabashka "test-writers-wrapping-babashka"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          (when (= (System/getenv "ThaigerSprint") "Thailand")
            (println "success"))
        ''
    );

    babashka-bin = expectSuccessBin (
      writeBabashkaBin "test-writers-wrapping-babashka-bin"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          (when (= (System/getenv "ThaigerSprint") "Thailand")
            (println "success"))
        ''
    );

    bash = expectSuccess (
      writeBash "test-writers-wrapping-bash"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          if [[ "$ThaigerSprint" == "Thailand" ]]; then
            echo "success"
          fi
        ''
    );

    bash-bin = expectSuccessBin (
      writeBashBin "test-writers-wrapping-bash-bin"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          if [[ "$ThaigerSprint" == "Thailand" ]]; then
            echo "success"
          fi
        ''
    );

    nim = expectSuccess (
      writeNim "test-writers-wrapping-nim"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          import os

          if getEnv("ThaigerSprint") == "Thailand":
            echo "success"
        ''
    );

    no-empty-wrapper =
      let
        bin = writeBashBin "bin" { makeWrapperArgs = [ ]; } "true";
      in
      runCommand "run-test-writers-wrapping-no-empty-wrapper" { } ''
        ls -A ${bin}/bin
        if [ $(ls -A ${bin}/bin | wc -l) -eq 1 ]; then
          touch $out
        else
          echo "Error: Empty wrapper was created" >&2
          exit 1
        fi
      '';

    python = expectSuccess (
      writePython3 "test-writers-wrapping-python"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          import os

          if os.environ.get("ThaigerSprint") == "Thailand":
              print("success")
        ''
    );

    rust = expectSuccess (
      writeRust "test-writers-wrapping-rust"
        {
          makeWrapperArgs = [
            "--set"
            "ThaigerSprint"
            "Thailand"
          ];
        }
        ''
          fn main(){
            if std::env::var("ThaigerSprint").unwrap() == "Thailand" {
              println!("success")
            }
          }
        ''
    );
  };
}
