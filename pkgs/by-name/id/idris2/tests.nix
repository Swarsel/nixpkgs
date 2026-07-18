{
  lib,
  stdenv,
  chez,
  idris2,
  idris2Packages,
  runCommand,
  tree,
  zsh,
}:

let
  testCompileAndRun =
    {
      code,
      testName,
      want,
      packages ? [ ],
    }:
    let
      inherit (idris2) pname;
      packageString = builtins.concatStringsSep " " (map (p: "--package " + p) packages);
    in
    runCommand "${pname}-${testName}"
      {
        # with idris2 compiled binaries assume zsh is available on darwin, but that
        # is not the case with pure nix environments. Thus, we need to include zsh
        # when we build for darwin in tests. While this is impure, this is also what
        # we find in real darwin hosts.
        strictDeps = true;
        nativeBuildInputs = [ chez ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ zsh ];
        meta.timeout = 60;
      }
      ''
        set -eo pipefail

        cat > packageTest.idr <<HERE
        ${code}
        HERE

        ${idris2}/bin/idris2 ${packageString} -o packageTest packageTest.idr

        patchShebangs --build ./build/exec/packageTest
        GOT=$(./build/exec/packageTest)

        if [ "$GOT" = "${want}" ]; then
          echo "${testName} SUCCESS: '$GOT' = '${want}'"
        else
          >&2 echo "Got '$GOT', want: '${want}'"
          exit 1
        fi

        touch $out
      '';

  testBuildIdris =
    {
      buildIdrisArgs,
      expectedTree,
      testName,
      # function that takes result of `buildIdris` and transforms it (commonly
      # by calling `.executable` or `.library {}` upon it):
      transformBuildIdrisOutput,
    }:
    let
      inherit (idris2) pname;
      idrisPkg = transformBuildIdrisOutput (idris2Packages.buildIdris buildIdrisArgs);
    in
    runCommand "${pname}-${testName}"
      {
        strictDeps = true;
        nativeBuildInputs = [ tree ];
        meta.timeout = 60;
      }
      ''
        GOT="$(tree ${idrisPkg} | tail -n +2)"

        if [ "$GOT" = '${expectedTree}' ]; then
          echo "${testName} SUCCESS"
        else
          >&2 echo "Got:
          $GOT"
          >&2 echo 'want:
          ${expectedTree}'
          exit 1
        fi

        touch $out
      '';
in
{
  buildExecutable = testBuildIdris {
    buildIdrisArgs = {
      src = runCommand "executable-package-src" { } ''
        mkdir $out

        cat > $out/Main.idr <<EOF
        module Main

        main : IO ()
        main = putStrLn "hi"
        EOF

        cat > $out/pkg.ipkg <<EOF
        package pkg
        modules = Main
        main = Main
        executable = mypkg
        EOF
      '';

      idrisLibraries = [ ];
      ipkgName = "pkg";
    };

    expectedTree = ''
      `-- bin
          `-- mypkg

      2 directories, 1 file'';

    testName = "executable-package";
    transformBuildIdrisOutput = pkg: pkg.executable;
  };

  buildLibrary = testBuildIdris {
    buildIdrisArgs = {
      src = runCommand "library-package-src" { } ''
        mkdir $out

        cat > $out/Main.idr <<EOF
        module Main

        import Compiler.ANF -- from Idris2Api

        hello : String
        hello = "world"
        EOF

        cat > $out/pkg.ipkg <<EOF
        package pkg
        modules = Main
        depends = idris2
        EOF
      '';

      idrisLibraries = [ idris2Packages.idris2Api ];
      ipkgName = "pkg";
    };

    expectedTree = ''
      `-- lib
          `-- idris2-${idris2.version}
              `-- pkg-0
                  |-- 2025081600
                  |   |-- Main.ttc
                  |   `-- Main.ttm
                  `-- pkg.ipkg

      5 directories, 3 files'';

    testName = "library-package";
    transformBuildIdrisOutput = pkg: pkg.library { withSource = false; };
  };

  buildLibraryWithSource = testBuildIdris {
    buildIdrisArgs = {
      src = runCommand "library-package-src" { } ''
        mkdir $out

        cat > $out/Main.idr <<EOF
        module Main

        import Compiler.ANF -- from Idris2Api

        hello : String
        hello = "world"
        EOF

        cat > $out/pkg.ipkg <<EOF
        package pkg
        modules = Main
        depends = idris2
        EOF
      '';

      idrisLibraries = [ idris2Packages.idris2Api ];
      ipkgName = "pkg";
    };

    expectedTree = ''
      `-- lib
          `-- idris2-${idris2.version}
              `-- pkg-0
                  |-- 2025081600
                  |   |-- Main.ttc
                  |   `-- Main.ttm
                  |-- Main.idr
                  `-- pkg.ipkg

      5 directories, 4 files'';

    testName = "library-with-source-package";
    transformBuildIdrisOutput = pkg: pkg.library { withSource = true; };
  };

  buildLibraryWithSourceRetroactively = testBuildIdris {
    buildIdrisArgs = {
      src = runCommand "library-package-src" { } ''
        mkdir $out

        cat > $out/Main.idr <<EOF
        module Main

        import Compiler.ANF -- from Idris2Api

        hello : String
        hello = "world"
        EOF

        cat > $out/pkg.ipkg <<EOF
        package pkg
        modules = Main
        depends = idris2
        EOF
      '';

      idrisLibraries = [ idris2Packages.idris2Api ];
      ipkgName = "pkg";
    };

    expectedTree = ''
      `-- lib
          `-- idris2-${idris2.version}
              `-- pkg-0
                  |-- 2025081600
                  |   |-- Main.ttc
                  |   `-- Main.ttm
                  |-- Main.idr
                  `-- pkg.ipkg

      5 directories, 4 files'';

    testName = "library-with-source-retro-package";
    transformBuildIdrisOutput = pkg: pkg.library'.withSource;
  };

  # Simple hello world compiles, runs and outputs as expected
  helloWorld = testCompileAndRun {
    code = ''
      module Main

      main : IO ()
      main = putStrLn "Hello World!"
    '';

    testName = "hello-world";
    want = "Hello World!";
  };

  # Data.Vect.Sort is available via --package contrib
  useContrib = testCompileAndRun {
    code = ''
      module Main

      import Data.Vect
      import Data.Vect.Sort  -- from contrib

      vect : Vect 3 Int
      vect = 3 :: 1 :: 5 :: Nil

      main : IO ()
      main = putStrLn $ show (sort vect)
    '';

    packages = [ "contrib" ];
    testName = "use-contrib";
    want = "[1, 3, 5]";
  };
}
