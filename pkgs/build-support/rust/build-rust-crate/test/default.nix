{
  lib,
  stdenv,
  buildPackages,
  buildRustCrate,
  callPackage,
  pkgsCross,
  releaseTools,
  runCommand,
  runCommandCC,
  symlinkJoin,
  testers,
  writeTextFile,
}:

let
  mkCrate =
    buildRustCrate: args:
    let
      p = {
        version = "0.1.0";
        authors = [ "Test <test@example.com>" ];
        crateName = "nixtestcrate";
      }
      // args;
    in
    buildRustCrate p;
  mkHostCrate = mkCrate buildRustCrate;

  mkCargoToml =
    {
      name,
      crateVersion ? "0.1.0",
      path ? "Cargo.toml",
    }:
    mkFile path ''
      [package]
      name = ${builtins.toJSON name}
      version = ${builtins.toJSON crateVersion}
    '';

  mkFile =
    destination: text:
    writeTextFile {
      inherit text;
      destination = "/${destination}";
      name = "src";
    };

  mkBin =
    name:
    mkFile name ''
      use std::env;
      fn main() {
        let name: String = env::args().nth(0).unwrap();
        println!("executed {}", name);
      }
    '';

  mkBinExtern =
    name: extern:
    mkFile name ''
      extern crate ${extern};
      fn main() {
        assert_eq!(${extern}::test(), 23);
      }
    '';

  mkTestFile =
    name: functionName:
    mkFile name ''
      #[cfg(test)]
      #[test]
      fn ${functionName}() {
        assert!(true);
      }
    '';
  mkTestFileWithMain =
    name: functionName:
    mkFile name ''
      #[cfg(test)]
      #[test]
      fn ${functionName}() {
        assert!(true);
      }

      fn main() {}
    '';

  mkLib = name: mkFile name "pub fn test() -> i32 { return 23; }";

  mkTest =
    crateArgs:
    let
      crate = mkHostCrate (
        removeAttrs crateArgs [
          "expectedTestOutputs"
          "expectedTestBinaries"
        ]
      );
      hasTests = crateArgs.buildTests or false;
      expectedTestOutputs = crateArgs.expectedTestOutputs or null;
      expectedTestBinaries = crateArgs.expectedTestBinaries or [ ];
      binaries = map (v: lib.escapeShellArg v.name) (crateArgs.crateBin or [ ]);
      isLib = crateArgs ? libName || crateArgs ? libPath;
      crateName = crateArgs.crateName or "nixtestcrate";
      libName = crateArgs.libName or crateName;

      libTestBinary =
        if !isLib then
          null
        else
          mkHostCrate {
            src = mkBinExtern "src/main.rs" libName;
            crateName = "run-test-${crateName}";
            dependencies = [ crate ];
          };

    in
    assert expectedTestOutputs != null -> hasTests;
    assert hasTests -> expectedTestOutputs != null;

    runCommand "run-buildRustCrate-${crateName}-test"
      {
        nativeBuildInputs = [ crate ];
      }
      (
        if !hasTests then
          ''
            ${lib.concatMapStringsSep "\n" (
              binary:
              # Can't actually run the binary when cross-compiling
              (lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) "type ") + binary
            ) binaries}
            ${lib.optionalString isLib ''
              test -e ${crate}/lib/*.rlib || exit 1
              ${lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) "test -x "} \
                ${libTestBinary}/bin/run-test-${crateName}
            ''}
            touch $out
          ''
        else if stdenv.hostPlatform == stdenv.buildPlatform then
          ''
            ${lib.concatMapStringsSep "\n" (
              b:
              "test -x ${crate}/tests/${lib.escapeShellArg b} || { echo 'expected test binary \"${b}\" not found in:'; ls ${crate}/tests; exit 23; }"
            ) expectedTestBinaries}
            for file in ${crate}/tests/*; do
              $file 2>&1 >> $out
            done
            set -e
            ${lib.concatMapStringsSep "\n" (
              o: "grep '${o}' $out || {  echo 'output \"${o}\" not found in:'; cat $out; exit 23; }"
            ) expectedTestOutputs}
          ''
        else
          ''
            for file in ${crate}/tests/*; do
              test -x "$file"
            done
            touch "$out"
          ''
      );

  /*
    Returns a derivation that asserts that the crate specified by `crateArgs`
    has the specified files as output.

    `name` is used as part of the derivation name that performs the checking.

    `mkCrate` can be used to override the `mkCrate` call/implementation to use to
    override the `buildRustCrate`, useful for cross compilation. Uses `mkHostCrate` by default.

    `crateArgs` is passed to `mkCrate` to build the crate with `buildRustCrate`

    `expectedFiles` contains a list of expected file paths in the output. E.g.
    `[ "./bin/my_binary" ]`.

    `output` specifies the name of the output to use. By default, the default
    output is used but e.g. `output = "lib";` will cause the lib output
    to be checked instead. You do not need to specify any directories.
  */
  assertOutputs =
    {
      crateArgs,
      expectedFiles,
      name,
      mkCrate ? mkHostCrate,
      output ? null,
    }:
    assert (builtins.isString name);
    assert (builtins.isAttrs crateArgs);
    assert (builtins.isList expectedFiles);

    let
      crate = mkCrate (removeAttrs crateArgs [ "expectedTestOutput" ]);
      crateOutput = if output == null then crate else crate."${output}";
      expectedFilesFile = writeTextFile {
        name = "expected-files-${name}";

        text =
          let
            sorted = builtins.sort (a: b: a < b) expectedFiles;
            concatenated = builtins.concatStringsSep "\n" sorted;
          in
          "${concatenated}\n";
      };
    in
    runCommand "assert-outputs-${name}"
      {
      }
      (
        ''
          local actualFiles=$(mktemp)

          cd "${crateOutput}"
          find . -type f \
            | sort \
        ''
        # sed out the hash because it differs per platform
        + ''
            | sed 's/-${crate.metadata}//g' \
            > "$actualFiles"
          diff -q ${expectedFilesFile} "$actualFiles" > /dev/null || {
            echo -e "\033[0;1;31mERROR: Difference in expected output files in ${crateOutput} \033[0m" >&2
            echo === Got:
            sed -e 's/^/  /' $actualFiles
            echo === Expected:
            sed -e 's/^/  /' ${expectedFilesFile}
            echo === Diff:
            diff -u ${expectedFilesFile} $actualFiles |\
              tail -n +3 |\
              sed -e 's/^/  /'
            exit 1
          }
          touch $out
        ''
      );

in
rec {

  test = releaseTools.aggregate {
    constituents = builtins.attrValues (lib.filterAttrs (_: v: lib.isDerivation v) tests);
    name = "buildRustCrate-tests";

    meta = {
      description = "Test cases for buildRustCrate";
      maintainers = [ ];
    };
  };

  tests = lib.recurseIntoAttrs (
    let
      cases = rec {
        # Regression test for https://github.com/NixOS/nixpkgs/issues/74071
        # Whenevever a build.rs file is generating files those should not be overlaid onto the actual source dir
        buildRsOutDirOverlay = {
          src = symlinkJoin {
            name = "buildrs-out-dir-overlay";

            paths = [
              (mkLib "src/lib.rs")
              (mkFile "build.rs" ''
                use std::env;
                use std::ffi::OsString;
                use std::fs;
                use std::path::Path;
                fn main() {
                  let out_dir = env::var_os("OUT_DIR").expect("OUT_DIR not set");
                  let out_file = Path::new(&out_dir).join("lib.rs");
                  fs::write(out_file, "invalid rust code!").expect("failed to write lib.rs");
                }
              '')
            ];
          };
        };

        buildScriptDeps =
          let
            depCrate =
              buildRustCrate: boolVal:
              mkCrate buildRustCrate {
                src = mkFile "src/lib.rs" ''
                  pub const baz: bool = ${boolVal};
                '';

                crateName = "bar";
              };
          in
          {
            src = symlinkJoin {
              name = "build-script-and-main";

              paths = [
                (mkFile "src/main.rs" ''
                  extern crate bar;
                  #[cfg(test)]
                  #[test]
                  fn baz_false() { assert!(!bar::baz); }
                  fn main() { }
                '')
                (mkFile "build.rs" ''
                  extern crate bar;
                  fn main() { assert!(bar::baz); }
                '')
              ];
            };

            buildDependencies = [ (depCrate buildPackages.buildRustCrate "true") ];
            buildTests = true;
            crateName = "foo";
            dependencies = [ (depCrate buildRustCrate "false") ];
            expectedTestOutputs = [ "test baz_false ... ok" ];
          };

        buildScriptFeatureEnv = {
          src = symlinkJoin {
            name = "build-script-feature-env";

            paths = [
              (mkFile "src/main.rs" ''
                #[cfg(test)]
                #[test]
                fn feature_not_visible() {
                  assert!(std::env::var("CARGO_FEATURE_SOME_FEATURE").is_err());
                  assert!(option_env!("CARGO_FEATURE_SOME_FEATURE").is_none());
                  assert!(std::env::var("CARGO_FEATURE_SOME_C++17_THING").is_err());
                  assert!(option_env!("CARGO_FEATURE_SOME_C++17_THING").is_none());
                  assert!(std::env::var("CARGO_FEATURE_ANOTHER_FEATURE").is_err());
                  assert!(option_env!("CARGO_FEATURE_ANOTHER_FEATURE").is_none());
                }
                fn main() {}
              '')
              (mkFile "build.rs" ''
                fn main() {
                  assert!(std::env::var("CARGO_FEATURE_SOME_FEATURE").is_ok());
                  assert!(option_env!("CARGO_FEATURE_SOME_FEATURE").is_none());
                  assert!(std::env::var("CARGO_FEATURE_SOME_C++17_THING").is_ok());
                  assert!(option_env!("CARGO_FEATURE_SOME_C++17_THING").is_none());
                  assert!(std::env::var("CARGO_FEATURE_ANOTHER_FEATURE").is_err());
                  assert!(option_env!("CARGO_FEATURE_ANOTHER_FEATURE").is_none());
                }
              '')
            ];
          };

          buildTests = true;
          crateName = "build-script-feature-env";
          expectedTestOutputs = [ "test feature_not_visible ... ok" ];

          features = [
            "some-feature"
            "some-c++17-thing"
            "crate/another_feature"
          ];
        };

        # Regression test for https://github.com/NixOS/nixpkgs/pull/88054
        # Build script output should be rewritten as valid env vars.
        buildScriptIncludeDirDeps =
          let
            depCrate = mkHostCrate {
              src = symlinkJoin {
                name = "build-script-and-include-dir-bar";

                paths = [
                  (mkFile "src/lib.rs" ''
                    fn main() { }
                  '')
                  (mkFile "build.rs" ''
                    use std::path::PathBuf;
                    fn main() { println!("cargo:include-dir={}/src", std::env::current_dir().unwrap_or(PathBuf::from(".")).to_str().unwrap()); }
                  '')
                ];
              };

              crateName = "bar";
            };
          in
          {
            src = symlinkJoin {
              name = "build-script-and-include-dir-foo";

              paths = [
                (mkFile "src/main.rs" ''
                  fn main() { }
                '')
                (mkFile "build.rs" ''
                  fn main() { assert!(std::env::var_os("DEP_BAR_INCLUDE_DIR").is_some()); }
                '')
              ];
            };

            buildDependencies = [ depCrate ];
            crateName = "foo";
            dependencies = [ depCrate ];
          };

        # Support new invocation prefix for build scripts `cargo::`
        # https://doc.rust-lang.org/cargo/reference/build-scripts.html#outputs-of-the-build-script
        buildScriptInvocationPrefix =
          let
            depCrate =
              buildRustCrate:
              mkCrate buildRustCrate {
                src = mkFile "build.rs" ''
                  fn main() {
                    // Old invocation prefix
                    // We likely won't see be mixing these syntaxes in the same build script in the wild.
                    println!("cargo:key_old=value_old");

                    // New invocation prefix
                    println!("cargo::metadata=key=value");
                    println!("cargo::metadata=key_complex=complex(value)");
                  }
                '';

                crateName = "bar";
              };
          in
          {
            src = symlinkJoin {
              name = "build-script-and-main-invocation-prefix";

              paths = [
                (mkFile "src/main.rs" ''
                  const BUILDFOO: &'static str = env!("BUILDFOO");

                  #[test]
                  fn build_foo_check() { assert!(BUILDFOO == "yes(check)"); }

                  fn main() { }
                '')
                (mkFile "build.rs" ''
                  use std::env;
                  fn main() {
                    assert!(env::var_os("DEP_BAR_KEY_OLD").expect("metadata key 'key_old' not set in dependency") == "value_old");
                    assert!(env::var_os("DEP_BAR_KEY").expect("metadata key 'key' not set in dependency") == "value");
                    assert!(env::var_os("DEP_BAR_KEY_COMPLEX").expect("metadata key 'key_complex' not set in dependency") == "complex(value)");

                    println!("cargo::rustc-env=BUILDFOO=yes(check)");
                  }
                '')
              ];
            };

            buildDependencies = [ (depCrate buildPackages.buildRustCrate) ];
            buildTests = true;
            crateName = "foo";
            dependencies = [ (depCrate buildRustCrate) ];
            expectedTestOutputs = [ "test build_foo_check ... ok" ];
          };

        crateBinNoPath1 = {
          src = mkBin "src/my_binary2.rs";
          crateBin = [ { name = "my-binary2"; } ];
        };

        crateBinNoPath2 = {
          src = symlinkJoin {
            name = "buildRustCrateMultipleBinariesCase";

            paths = [
              (mkBin "src/bin/my_binary3.rs")
              (mkBin "src/bin/my_binary4.rs")
            ];
          };

          crateBin = [
            { name = "my-binary3"; }
            { name = "my-binary4"; }
          ];
        };

        crateBinNoPath3 = {
          src = mkBin "src/bin/main.rs";
          crateBin = [ { name = "my-binary5"; } ];
        };

        crateBinNoPath4 = {
          src = mkBin "src/main.rs";
          crateBin = [ { name = "my-binary6"; } ];
        };

        crateBinRename1 = {
          src = mkBinExtern "src/main.rs" "foo_renamed";
          crateBin = [ { name = "my-binary-rename1"; } ];

          crateRenames = {
            "foo" = "foo_renamed";
          };

          dependencies = [
            (mkHostCrate {
              src = mkLib "src/lib.rs";
              crateName = "foo";
            })
          ];
        };

        crateBinRename2 = {
          src = mkBinExtern "src/main.rs" "foo_renamed";
          crateBin = [ { name = "my-binary-rename2"; } ];

          crateRenames = {
            "foo" = "foo_renamed";
          };

          dependencies = [
            (mkHostCrate {
              src = mkLib "src/lib.rs";
              crateName = "foo";
              libName = "foolib";
            })
          ];
        };

        crateBinRenameMultiVersion =
          let
            crateWithVersion =
              version:
              mkHostCrate {
                inherit version;

                src = mkFile "src/lib.rs" ''
                  pub const version: &str = "${version}";
                '';

                crateName = "my_lib";
              };
            depCrate01 = crateWithVersion "0.1.2";
            depCrate02 = crateWithVersion "0.2.1";
          in
          {
            src = symlinkJoin {
              name = "my_bin_src";

              paths = [
                (mkFile "src/main.rs" ''
                  #[test]
                  fn my_lib_01() { assert_eq!(lib01::version, "0.1.2"); }

                  #[test]
                  fn my_lib_02() { assert_eq!(lib02::version, "0.2.1"); }

                  fn main() { }
                '')
              ];
            };

            buildTests = true;
            crateName = "my_bin";

            crateRenames = {
              "my_lib" = [
                {
                  version = "0.1.2";
                  rename = "lib01";
                }
                {
                  version = "0.2.1";
                  rename = "lib02";
                }
              ];
            };

            dependencies = [
              depCrate01
              depCrate02
            ];

            expectedTestOutputs = [
              "test my_lib_01 ... ok"
              "test my_lib_02 ... ok"
            ];
          };

        crateBinWithPath = {
          src = mkBin "src/foobar.rs";

          crateBin = [
            {
              name = "test_binary1";
              path = "src/foobar.rs";
            }
          ];
        };

        # This used to be supported by cargo but as of 1.40.0 I can't make it work like that with just cargo anymore.
        # This might be a regression or deprecated thing they finally removed…
        # customLibName =  { libName = "test_lib"; src = mkLib "src/test_lib.rs"; };
        # rustLibTestsCustomLibName = {
        #   libName = "test_lib";
        #   src = mkTestFile "src/test_lib.rs" "foo";
        #   buildTests = true;
        #   expectedTestOutputs = [ "test foo ... ok" ];
        # };
        customLibNameAndLibPath = {
          src = mkLib "src/best-lib.rs";
          libName = "test_lib";
          libPath = "src/best-lib.rs";
        };

        libPath = {
          src = mkLib "src/my_lib.rs";
          libPath = "src/my_lib.rs";
        };

        linkAgainstRlibCrate = {
          src = mkFile "src/main.rs" ''
            extern crate somerlib;
            fn main() {}
          '';

          crateName = "foo";

          dependencies = [
            (mkHostCrate {
              src = mkLib "src/lib.rs";
              crateName = "somerlib";
              type = [ "rlib" ];
            })
          ];
        };

        # Regression test for https://github.com/NixOS/nixpkgs/pull/83379
        # link flag order should be preserved
        linkOrder = {
          src = symlinkJoin {
            name = "buildrs-out-dir-overlay";

            paths = [
              (mkFile "build.rs" ''
                fn main() {
                  // in the other order, linkage will fail
                  println!("cargo:rustc-link-lib=b");
                  println!("cargo:rustc-link-lib=a");
                }
              '')
              (mkFile "src/main.rs" ''
                extern "C" {
                  fn hello_world();
                }
                fn main() {
                  unsafe {
                    hello_world();
                  }
                }
              '')
            ];
          };

          buildInputs =
            let
              compile =
                name: text:
                let
                  src = writeTextFile {
                    inherit text;
                    name = "${name}-src.c";
                  };
                in
                runCommandCC name { } ''
                  mkdir -p $out/lib
                  # Note: On darwin (which defaults to clang) we have to add
                  # `-undefined dynamic_lookup` as otherwise the compilation fails.
                  $CC -shared \
                    ${lib.optionalString stdenv.hostPlatform.isDarwin "-undefined dynamic_lookup"} \
                    -o $out/lib/${name}${stdenv.hostPlatform.extensions.library} ${src}
                '';
              b = compile "libb" ''
                #include <stdio.h>

                void hello();

                void hello_world() {
                  hello();
                  printf(" world!\n");
                }
              '';
              a = compile "liba" ''
                #include <stdio.h>

                void hello() {
                  printf("hello");
                }
              '';
            in
            [
              a
              b
            ];
        };

        # The `lints` attr mirrors Cargo.toml's `[lints]` table and is
        # translated to rustc `-A`/`-W`/`-D`/`-F` flags. Lower-priority
        # entries are emitted first so that higher-priority specific lints
        # can override them. Here `-D unused` (priority -1) is followed by
        # `-A dead_code` (default priority 0); the build only succeeds if
        # both flags reach rustc in that order.
        lintsPriority = {
          src = mkFile "src/lib.rs" ''
            #![allow(nonstandard_style)]
            fn dead() {}
            pub fn alive() {}
          '';

          lints.rust = {
            dead_code = "allow";

            unused = {
              level = "deny";
              priority = -1;
            };
          };
        };

        # Default (null) inherits extraRustcOpts for proc-macros.
        procMacroExtraOptsInherit = {
          src = mkFile "src/lib.rs" ''
            #[cfg(not(target_only))]
            compile_error!("extraRustcOpts not inherited by proc-macro");
            use proc_macro as _;
          '';

          edition = "2018";
          extraRustcOpts = [ "--cfg=target_only" ];
          procMacro = true;
        };

        # When set, extraRustcOptsForProcMacro replaces extraRustcOpts
        # for proc-macro crates.
        procMacroExtraOptsOverride = {
          src = mkFile "src/lib.rs" ''
            #[cfg(target_only)]
            compile_error!("extraRustcOpts leaked into proc-macro");
            #[cfg(not(host_only))]
            compile_error!("extraRustcOptsForProcMacro not applied");
            use proc_macro as _;
          '';

          edition = "2018";
          extraRustcOpts = [ "--cfg=target_only" ];
          extraRustcOptsForProcMacro = [ "--cfg=host_only" ];
          procMacro = true;
        };

        procMacroInPrelude = {
          src = symlinkJoin {
            name = "proc-macro-in-prelude";

            paths = [
              (mkFile "src/lib.rs" ''
                use proc_macro::TokenTree;
              '')
            ];
          };

          edition = "2018";
          procMacro = true;
        };

        rustBinTestsCargoBinExe = {
          src = symlinkJoin {
            name = "rust-bin-tests-cargo-bin-exe";

            paths = [
              (mkFile "src/main.rs" ''
                fn main() { println!("hello from my-crate"); }
              '')
              (mkFile "tests/run_bin.rs" ''
                #[test]
                fn runs_binary() {
                    let bin = env!("CARGO_BIN_EXE_my-crate");
                    let out = std::process::Command::new(bin)
                        .output()
                        .expect("spawn");
                    assert!(out.status.success());
                    assert_eq!(
                        String::from_utf8_lossy(&out.stdout).trim(),
                        "hello from my-crate"
                    );
                }
              '')
            ];
          };

          buildTests = true;
          # Integration tests locate the crate's own binary via
          # `env!("CARGO_BIN_EXE_<name>")`, which cargo sets automatically.
          crateName = "my-crate";

          expectedTestOutputs = [
            "test runs_binary ... ok"
          ];
        };

        rustBinTestsCargoBinExeAutoDetect = {
          src = symlinkJoin {
            name = "rust-bin-tests-cargo-bin-exe-auto";

            paths = [
              (mkFile "src/lib.rs" "")
              (mkFile "src/bin/tool-a.rs" ''
                fn main() { println!("tool-a ran"); }
              '')
              (mkFile "src/bin/tool-b.rs" ''
                fn main() { println!("tool-b ran"); }
              '')
              (mkFile "tests/run_tools.rs" ''
                #[test]
                fn runs_both() {
                    for (bin, want) in [
                        (env!("CARGO_BIN_EXE_tool-a"), "tool-a ran"),
                        (env!("CARGO_BIN_EXE_tool-b"), "tool-b ran"),
                    ] {
                        let out = std::process::Command::new(bin)
                            .output()
                            .expect("spawn");
                        assert!(out.status.success());
                        assert_eq!(String::from_utf8_lossy(&out.stdout).trim(), want);
                    }
                }
              '')
            ];
          };

          buildTests = true;
          # Verify CARGO_BIN_EXE_<name> is also set for auto-detected
          # src/bin/*.rs binaries, not just src/main.rs or explicit
          # crateBin entries.
          crateName = "multi-bin";

          expectedTestOutputs = [
            "test runs_both ... ok"
          ];
        };

        rustBinTestsCombined = {
          src = symlinkJoin {
            name = "rust-bin-tests-combined";

            paths = [
              (mkTestFileWithMain "src/main.rs" "src_main")
              (mkTestFile "tests/foo.rs" "tests_foo")
              (mkTestFile "tests/bar.rs" "tests_bar")
            ];
          };

          buildTests = true;

          expectedTestOutputs = [
            "test src_main ... ok"
            "test tests_foo ... ok"
            "test tests_bar ... ok"
          ];
        };

        rustBinTestsFlatMainSuffix = {
          # A flat-style test whose name happens to end in _main must keep
          # its suffix — only tests/<dir>/main.rs gets the _main stripped.
          src = symlinkJoin {
            name = "rust-bin-tests-flat-main-suffix";

            paths = [
              (mkTestFileWithMain "src/main.rs" "src_main")
              (mkTestFile "tests/foo_main.rs" "flat_test")
            ];
          };

          buildTests = true;
          expectedTestBinaries = [ "foo_main" ];

          expectedTestOutputs = [
            "test src_main ... ok"
            "test flat_test ... ok"
          ];
        };

        rustBinTestsSubdirCombined = {
          src = symlinkJoin {
            name = "rust-bin-tests-subdir-combined";

            paths = [
              (mkTestFileWithMain "src/main.rs" "src_main")
              (mkTestFile "tests/foo/main.rs" "tests_foo")
              (mkTestFile "tests/bar/main.rs" "tests_bar")
            ];
          };

          buildTests = true;

          # Cargo names tests/<dir>/main.rs as <dir>, not <dir>_main.
          expectedTestBinaries = [
            "foo"
            "bar"
          ];

          expectedTestOutputs = [
            "test src_main ... ok"
            "test tests_foo ... ok"
            "test tests_bar ... ok"
          ];
        };

        rustCargoTomlInSubDir = {
          src = symlinkJoin {
            name = "find-cargo-toml";

            paths = [
              (mkCargoToml { name = "ignoreMe"; })
              (mkTestFileWithMain "src/main.rs" "ignore_main")

              (mkCargoToml {
                name = "rustCargoTomlInSubDir";
                path = "subdir/Cargo.toml";
              })
              (mkTestFileWithMain "subdir/src/main.rs" "src_main")
              (mkTestFile "subdir/tests/foo/main.rs" "tests_foo")
              (mkTestFile "subdir/tests/bar/main.rs" "tests_bar")
            ];
          };

          buildTests = true;

          expectedTestOutputs = [
            "test src_main ... ok"
            "test tests_foo ... ok"
            "test tests_bar ... ok"
          ];

          # The "workspace_member" can be set to the sub directory with the crate to build.
          # By default ".", meaning the top level directory is assumed.
          # Using null will trigger a search.
          workspace_member = null;
        };

        rustCargoTomlInTopDir =
          let
            withoutCargoTomlSearch = removeAttrs rustCargoTomlInSubDir [ "workspace_member" ];
          in
          withoutCargoTomlSearch
          // {
            expectedTestOutputs = [
              "test ignore_main ... ok"
            ];
          };

        rustLibTestsCustomLibPath = {
          src = mkTestFile "src/test_path.rs" "bar";
          buildTests = true;
          expectedTestOutputs = [ "test bar ... ok" ];
          libPath = "src/test_path.rs";
        };

        rustLibTestsCustomLibPathWithTests = {
          src = symlinkJoin {
            name = "rust-lib-tests-custom-lib-path-with-tests-dir";

            paths = [
              (mkTestFile "src/test_path.rs" "bar")
              (mkTestFile "tests/something.rs" "something")
            ];
          };

          buildTests = true;

          expectedTestOutputs = [
            "test bar ... ok"
            "test something ... ok"
          ];

          libPath = "src/test_path.rs";
        };

        rustLibTestsDefault = {
          src = mkTestFile "src/lib.rs" "baz";
          buildTests = true;
          expectedTestOutputs = [ "test baz ... ok" ];
        };

        rustLibTestsWithDevDependency =
          let
            devDep = mkHostCrate {
              src = mkLib "src/lib.rs";
              crateName = "dev-dep";
            };
          in
          {
            src = mkFile "src/lib.rs" ''
              #[cfg(test)]
              mod tests {
                  #[test]
                  fn uses_dev_dep() {
                      assert_eq!(dev_dep::test(), 23);
                  }
              }
            '';

            buildTests = true;
            devDependencies = [ devDep ];
            expectedTestOutputs = [ "test tests::uses_dev_dep ... ok" ];
          };

        srcLib = {
          src = mkLib "src/lib.rs";
        };
      };
      brotliCrates = (callPackage ./brotli-crates.nix { });
      rcgenCrates = callPackage ./rcgen-crates.nix {
        # Suppress deprecation warning
        buildRustCrate = null;
      };
      tests = lib.mapAttrs (
        key: value: mkTest (value // lib.optionalAttrs (!value ? crateName) { crateName = key; })
      ) cases;
    in
    tests
    // {

      allocNoStdLibTest =
        let
          pkg = brotliCrates.alloc_no_stdlib_1_3_0 { };
        in
        runCommand "run-alloc-no-stdlib-test-cmd"
          {
            nativeBuildInputs = [ pkg ];
          }
          ''
            test -e ${pkg}/bin/example && touch $out
          '';

      brotliDecompressorTest =
        let
          pkg = brotliCrates.brotli_decompressor_1_3_1 { };
        in
        runCommand "run-brotli-decompressor-test-cmd"
          {
            nativeBuildInputs = [ pkg ];
          }
          ''
            test -e ${pkg}/bin/brotli-decompressor && touch $out
          '';

      brotliTest =
        let
          pkg = brotliCrates.brotli_2_5_0 { };
        in
        runCommand "run-brotli-test-cmd"
          {
            nativeBuildInputs = [ pkg ];
          }
          (
            if stdenv.hostPlatform == stdenv.buildPlatform then
              ''
                ${pkg}/bin/brotli -c ${pkg}/bin/brotli > /dev/null && touch $out
              ''
            else
              ''
                test -x '${pkg}/bin/brotli' && touch $out
              ''
          );

      crateBinNoPath1Outputs = assertOutputs {
        crateArgs = {
          src = mkBin "src/my_binary2.rs";
          crateBin = [ { name = "my-binary2"; } ];
        };

        expectedFiles = [
          "./bin/my-binary2"
        ];

        name = "crateBinNoPath1";
      };

      crateBinWithPathOutputs = assertOutputs {
        crateArgs = {
          src = mkBin "src/foobar.rs";

          crateBin = [
            {
              name = "test_binary1";
              path = "src/foobar.rs";
            }
          ];
        };

        expectedFiles = [
          "./bin/test_binary1"
        ];

        name = "crateBinWithPath";
      };

      crateBinWithPathOutputsDebug = assertOutputs {
        crateArgs = {
          src = mkBin "src/foobar.rs";

          crateBin = [
            {
              name = "test_binary1";
              path = "src/foobar.rs";
            }
          ];

          release = false;
        };

        expectedFiles = [
          "./bin/test_binary1"
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          # On Darwin, the debug symbols are in a separate directory.
          "./bin/test_binary1.dSYM/Contents/Info.plist"
          "./bin/test_binary1.dSYM/Contents/Resources/DWARF/test_binary1"
          "./bin/test_binary1.dSYM/Contents/Resources/Relocations/${stdenv.hostPlatform.rust.platform.arch}/test_binary1.yml"
        ];

        name = "crateBinWithPath";
      };

      crateGnu64TargetEnv = assertOutputs {
        crateArgs = {
          src = symlinkJoin {
            name = "gnu64-crate-target-env-sources";

            paths = [
              (mkFile "build.rs" ''
                fn main() {
                  assert_eq!(std::env::var("CARGO_CFG_TARGET_ENV"), Ok("gnu".to_string()));
                }
              '')
              (mkFile "src/main.rs" ''
                use std::env;
                #[cfg(target_env = "gnu")]
                fn main() {
                  let name: String = env::args().nth(0).unwrap();
                  println!("executed {}", name);
                }
              '')
            ];
          };

          crateBin = [ { name = "gnu64-crate-target-env"; } ];
          crateName = "gnu64-crate-target-env";
        };

        expectedFiles = [
          "./bin/gnu64-crate-target-env"
        ];

        mkCrate = mkCrate pkgsCross.gnu64.buildRustCrate;
        name = "gnu64-crate-target-env";
      };

      crateLibOutputs = assertOutputs {
        crateArgs = {
          src = mkLib "src/lib.rs";
          libName = "test_lib";
          libPath = "src/lib.rs";
          type = [ "rlib" ];
        };

        expectedFiles = [
          "./nix-support/propagated-build-inputs"
          "./lib/libtest_lib.rlib"
          "./lib/link"
        ];

        name = "crateLib";
        output = "lib";
      };

      crateLibOutputsDebug = assertOutputs {
        crateArgs = {
          src = mkLib "src/lib.rs";
          libName = "test_lib";
          libPath = "src/lib.rs";
          release = false;
          type = [ "rlib" ];
        };

        expectedFiles = [
          "./nix-support/propagated-build-inputs"
          "./lib/libtest_lib.rlib"
          "./lib/link"
        ];

        name = "crateLib";
        output = "lib";
      };

      crateLibOutputsWasm32 = assertOutputs {
        crateArgs = {
          src = mkLib "src/lib.rs";
          libName = "test_lib";
          libPath = "src/lib.rs";
          type = [ "cdylib" ];
        };

        expectedFiles = [
          "./nix-support/propagated-build-inputs"
          "./lib/test_lib.wasm"
          "./lib/link"
        ];

        mkCrate = mkCrate pkgsCross.wasm32-unknown-none.buildRustCrate;
        name = "wasm32-crate-lib";
        output = "lib";
      };

      crateWasm32BinHyphens = assertOutputs {
        crateArgs = {
          src = mkBin "src/main.rs";
          crateBin = [ { name = "wasm32-crate-bin-hyphens"; } ];
          crateName = "wasm32-crate-bin-hyphens";
        };

        expectedFiles = [
          "./bin/wasm32-crate-bin-hyphens.wasm"
        ];

        mkCrate = mkCrate pkgsCross.wasm32-unknown-none.buildRustCrate;
        name = "wasm32-crate-bin-hyphens";
      };

      crateWasm32TargetEnv = assertOutputs {
        crateArgs = {
          src = symlinkJoin {
            name = "wasm32-crate-target-env-sources";

            paths = [
              (mkFile "build.rs" ''
                fn main() {
                  assert_eq!(std::env::var("CARGO_CFG_TARGET_ENV"), Ok("".to_string()));
                }
              '')
              (mkFile "src/main.rs" ''
                use std::env;
                #[cfg(target_env = "")]
                fn main() {
                  let name: String = env::args().nth(0).unwrap();
                  println!("executed {}", name);
                }
              '')
            ];
          };

          crateBin = [ { name = "wasm32-crate-target-env"; } ];
          crateName = "wasm32-crate-target-env";
        };

        expectedFiles = [
          "./bin/wasm32-crate-target-env.wasm"
        ];

        mkCrate = mkCrate pkgsCross.wasm32-unknown-none.buildRustCrate;
        name = "gnu64-crate-target-env";
      };

      # A `deny` lint from the lints table should actually fail the build.
      lintsDenyFails =
        let
          crate = mkHostCrate {
            src = mkFile "src/lib.rs" ''
              fn dead() {}
              pub fn alive() {}
            '';

            crateName = "lintsDenyFails";
            lints.rust.dead_code = "deny";
          };
          failed = testers.testBuildFailure crate;
        in
        runCommand "assert-lintsDenyFails" { inherit failed; } ''
          grep -q 'function .dead. is never used' "$failed/testBuildFailure.log"
          grep -q '\-D dead.code' "$failed/testBuildFailure.log"
          touch $out
        '';

      # Test that propagatedBuildInputs declared in a crate override are
      # collected by completePropagatedBuildInputs and propagate transitively
      # to all crates that depend on it.
      propagatedBuildInputsTest =
        let
          fakeNativeLib = runCommand "fake-native-lib" { } "mkdir -p $out/lib && touch $out/lib/libfoo.a";

          # Library crate that declares a native dep via propagatedBuildInputs
          libCrate = mkHostCrate {
            src = mkLib "src/lib.rs";
            propagatedBuildInputs = [ fakeNativeLib ];
            crateName = "mylib";
          };

          # Binary crate with a direct dependency on libCrate
          binCrate = mkHostCrate {
            src = mkFile "src/main.rs" "fn main() {}";
            crateName = "mybin";
            dependencies = [ libCrate ];
          };

          # Intermediate library that depends on libCrate
          transitiveLib = mkHostCrate {
            src = mkLib "src/lib.rs";
            crateName = "transitivelib";
            dependencies = [ libCrate ];
          };

          # Binary crate that only depends on transitiveLib (not libCrate directly)
          transitiveBin = mkHostCrate {
            src = mkFile "src/main.rs" "fn main() {}";
            crateName = "transitivebin";
            dependencies = [ transitiveLib ];
          };
        in
        runCommand "propagated-build-inputs-test"
          {
            binCrateInputs = binCrate.completePropagatedBuildInputs;
            libCrateInputs = libCrate.completePropagatedBuildInputs;
            transitiveBinInputs = transitiveBin.completePropagatedBuildInputs;
          }
          ''
            # libCrate itself should have fakeNativeLib in completePropagatedBuildInputs
            echo "$libCrateInputs" | grep -q "${fakeNativeLib}" || {
              echo "ERROR: fakeNativeLib not in libCrate.completePropagatedBuildInputs"
              exit 1
            }

            # binCrate depends on libCrate, so fakeNativeLib should propagate
            echo "$binCrateInputs" | grep -q "${fakeNativeLib}" || {
              echo "ERROR: fakeNativeLib not propagated to binCrate.completePropagatedBuildInputs"
              exit 1
            }

            # transitiveBin → transitiveLib → libCrate: fakeNativeLib should propagate transitively
            echo "$transitiveBinInputs" | grep -q "${fakeNativeLib}" || {
              echo "ERROR: fakeNativeLib not transitively propagated to transitiveBin.completePropagatedBuildInputs"
              exit 1
            }

            touch $out
          '';

      rcgenTest =
        let
          pkg = rcgenCrates.rootCrate.build;
        in
        runCommand "run-rcgen-test-cmd"
          {
            nativeBuildInputs = [ pkg ];
          }
          (
            if stdenv.hostPlatform == stdenv.buildPlatform then
              ''
                ${pkg}/bin/rcgen && touch $out
              ''
            else
              ''
                test -x '${pkg}/bin/rcgen' && touch $out
              ''
          );

      # `useClippy = true` with the default `capLints` (which resolves to
      # `"allow"` when `lints` is empty) must still build: the cap silences
      # clippy lints just like rustc lints. Same source as the failing test
      # above — only the `lints` table differs.
      useClippyDefaultCapAllows = mkHostCrate {
        src = mkFile "src/lib.rs" ''
          pub fn check() -> bool {
            1 == 1
          }
        '';

        crateName = "useClippyDefaultCapAllows";
        useClippy = true;
      };

      # `useClippy = true` plus a denied clippy lint should fail the build,
      # proving clippy-driver (not plain rustc) compiled the crate. The
      # `clippy::` prefix in the diagnostic is the fingerprint: rustc has no
      # such lint group.
      useClippyDenyFails =
        let
          crate = mkHostCrate {
            src = mkFile "src/lib.rs" ''
              pub fn check() -> bool {
                1 == 1
              }
            '';

            crateName = "useClippyDenyFails";
            lints.clippy.eq_op = "deny";
            useClippy = true;
          };
          failed = testers.testBuildFailure crate;
        in
        runCommand "assert-useClippyDenyFails" { inherit failed; } ''
          grep -q 'clippy::eq.op' "$failed/testBuildFailure.log"
          grep -q 'equal expressions' "$failed/testBuildFailure.log"
          touch $out
        '';

      # A library compiled by clippy-driver must produce an `.rlib` that a
      # plain-rustc dependent can link against and run. This is the property
      # that makes `useClippy` safe to flip per-crate.
      useClippyRlibLinkCompat =
        let
          libCrate = mkHostCrate {
            src = mkFile "src/lib.rs" ''
              pub fn test() -> i32 {
                23
              }
            '';

            crateName = "clippylib";
            useClippy = true;
          };
          binCrate = mkHostCrate {
            src = mkBinExtern "src/main.rs" "clippylib";
            crateName = "clippybin";
            dependencies = [ libCrate ];
          };
        in
        runCommand "run-useClippyRlibLinkCompat" { nativeBuildInputs = [ binCrate ]; } (
          if stdenv.hostPlatform == stdenv.buildPlatform then
            ''
              ${binCrate}/bin/clippybin && touch $out
            ''
          else
            ''
              test -x '${binCrate}/bin/clippybin' && touch $out
            ''
        );
    }
  );
}
