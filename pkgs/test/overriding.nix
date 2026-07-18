{
  lib,
  pkgs,
  stdenvNoCC,
}:

let
  tests =
    tests-stdenv
    // test-extendMkDerivation
    // tests-fetchgit
    // tests-fetchhg
    // tests-fetchurl
    // tests-go
    // tests-python;

  tests-stdenv =
    let
      addEntangled =
        origOverrideAttrs: f:
        origOverrideAttrs (
          lib.composeExtensions f (
            self: super: {
              passthru = super.passthru // {
                entangled = super.passthru.entangled.overrideAttrs f;
                overrideAttrs = addEntangled self.overrideAttrs;
              };
            }
          )
        );

      entangle =
        pkg1: pkg2:
        pkg1.overrideAttrs (
          self: super: {
            passthru = super.passthru // {
              entangled = pkg2;
              overrideAttrs = addEntangled self.overrideAttrs;
            };
          }
        );

      example = entangle pkgs.hello pkgs.figlet;

      overrides1 = example.overrideAttrs (_: super: { pname = "a-better-${super.pname}"; });

      repeatedOverrides = overrides1.overrideAttrs (
        _: super: { pname = "${super.pname}-with-blackjack"; }
      );
    in
    {
      overriding-using-only-attrset = {
        expected = "hello-overriden";
        expr = (pkgs.hello.overrideAttrs { pname = "hello-overriden"; }).pname;
      };

      overriding-using-only-attrset-no-final-attrs = {
        expected = "hello-no-final-attrs-overridden";

        expr =
          ((stdenvNoCC.mkDerivation { pname = "hello-no-final-attrs"; }).overrideAttrs {
            pname = "hello-no-final-attrs-overridden";
          }).pname;

        name = "overriding-using-only-attrset-no-final-attrs";
      };

      repeatedOverrides-entangled-pname = {
        expected = "a-better-figlet-with-blackjack";
        expr = repeatedOverrides.entangled.pname;
      };

      repeatedOverrides-pname = {
        expected = "a-better-hello-with-blackjack";
        expr = repeatedOverrides.pname;
      };

      structuredAttrs-allowedRequisites-nullability = {
        expected = true;

        expr =
          lib.hasPrefix builtins.storeDir
            (pkgs.stdenv.mkDerivation {
              inherit (pkgs.hello) pname version src;
              __structuredAttrs = true;
              allowedRequisites = null;
            }).drvPath;
      };
    };

  test-extendMkDerivation =
    let
      mkLocalDerivation = lib.extendMkDerivation {
        constructDrv = pkgs.stdenv.mkDerivation;

        excludeDrvArgNames = [
          "specialArg"
        ];

        extendDrvArgs =
          finalAttrs:
          {
            allowSubstitute ? false,
            preferLocalBuild ? true,
            specialArg ? (_: false),
            ...
          }@args:
          {
            inherit preferLocalBuild allowSubstitute;

            passthru = args.passthru or { } // {
              greeting = if specialArg "Hi!" then "Hi!" else "Hello!";
            };
          };
      };

      helloLocalPlainAttrs = {
        inherit (pkgs.hello) pname version src;
        specialArg = throw "specialArg is broken.";
      };

      helloLocalPlain = mkLocalDerivation helloLocalPlainAttrs;

      helloLocal = mkLocalDerivation (
        finalAttrs:
        helloLocalPlainAttrs
        // {
          passthru = pkgs.hello.passthru or { } // {
            bar = "${finalAttrs.passthru.foo}b";
            foo = "a";
          };
        }
      );

      hiLocal = mkLocalDerivation (
        helloLocalPlainAttrs
        // {
          specialArg = s: lib.stringLength s == 3;
        }
      );
    in
    {
      extendMkDerivation-helloLocal-finalAttrs = {
        expected = "ab";
        expr = helloLocal.bar;
      };

      extendMkDerivation-helloLocal-imp-arguments = {
        expected = true;
        expr = helloLocal.preferLocalBuild;
      };

      extendMkDerivation-helloLocal-plain-equivalence = {
        expected = helloLocalPlain.drvPath;
        expr = helloLocal.drvPath;
      };

      extendMkDerivation-helloLocal-specialArg = {
        expected = "Hi!";
        expr = hiLocal.greeting;
      };
    };

  /**
    Take two positional arguments `fakeHash` and `partialHash`,
    and return a modified version of fakeHash whose hash body is partially substituted by `partialHash` from the beginning,
    used to assert a specific fake hash variant is used by an overridden FOD.

    # Inputs

    `fakeHash`

    : The specified zero fake hash

    `partialHash`

    : A trimmed non-zero hash body, to substitute the beginning of the zero hash body.
  */
  genNonzeroFakeHash =
    fakeHash:
    let
      isSRIHash = lib.hasInfix "-" fakeHash;
      defaultHashAlgo = lib.optionalString isSRIHash lib.head (lib.splitString "-" lib.fakeHash);
      defaultHashPrefix = lib.optionalString isSRIHash (defaultHashAlgo + "-");
      defaultHashBody = lib.removePrefix defaultHashPrefix fakeHash;
    in
    partialHash:
    defaultHashPrefix
    + partialHash
    + (lib.substring (lib.stringLength partialHash) (lib.stringLength defaultHashBody) defaultHashBody);

  tests-fetchgit =
    let
      fakeSha256-1 = genNonzeroFakeHash lib.fakeSha256 "1";
      fakeHash-2 = genNonzeroFakeHash lib.fakeHash "B";
      src-with-sha256 = pkgs.fetchgit {
        sha256 = fakeSha256-1;
        url = "https://example.com/source.git";
      };
    in
    {
      test-fetchgit-hash-compat = {
        expected = {
          outputHash = fakeSha256-1;
          outputHashAlgo = "sha256";
        };

        expr = {
          inherit (src-with-sha256)
            outputHash
            outputHashAlgo
            ;
        };
      };

      test-fetchgit-overrideAttrs-hash = {
        expected = {
          outputHash = fakeHash-2;
          outputHashAlgo = null;
        };

        expr = {
          inherit (src-with-sha256.overrideAttrs { hash = fakeHash-2; })
            outputHash
            outputHashAlgo
            ;
        };
      };

      test-fetchurl-overrideAttrs-hash-empty = {
        expected = {
          outputHash = lib.fakeHash;
          outputHashAlgo = null;
        };

        expr = {
          inherit (src-with-sha256.overrideAttrs { hash = ""; })
            outputHash
            outputHashAlgo
            ;
        };
      };
    };

  tests-fetchurl =
    let
      fakeSha256-1 = genNonzeroFakeHash lib.fakeSha256 "1";
      fakeHash-2 = genNonzeroFakeHash lib.fakeHash "B";
      src-with-sha256 = pkgs.fetchurl {
        sha256 = fakeSha256-1;
        url = "https://example.com/source.tar.gz";
      };
    in
    {
      test-fetchurl-hash-compat = {
        expected = {
          outputHash = fakeSha256-1;
          outputHashAlgo = "sha256";
        };

        expr = {
          inherit (src-with-sha256)
            outputHash
            outputHashAlgo
            ;
        };
      };

      test-fetchurl-overrideAttrs-hash = {
        expected = {
          outputHash = fakeHash-2;
          outputHashAlgo = null;
        };

        expr = {
          inherit (src-with-sha256.overrideAttrs { hash = fakeHash-2; })
            outputHash
            outputHashAlgo
            ;
        };
      };

      test-fetchurl-overrideAttrs-hash-empty = {
        expected = {
          outputHash = lib.fakeHash;
          outputHashAlgo = null;
        };

        expr = {
          inherit (src-with-sha256.overrideAttrs { hash = ""; })
            outputHash
            outputHashAlgo
            ;
        };
      };
    };

  tests-fetchhg =
    let
      ruamel_0_18_14-hash = "sha256-HDkPPp1xI3uoGYlS9mwPp1ZjG2gKvx6vog0Blj6tBuI=";
      ruamel_0_18_14-src = pkgs.fetchhg {
        hash = ruamel_0_18_14-hash;
        rev = "0.18.14";
        url = "http://hg.code.sf.net/p/ruamel-yaml/code";
      };
      ruamel_0_17_21-hash = "sha256-6PV0NyPQfd+4RBqoj5vJaOHShx+TJVHD2IamRinU0VU=";
      ruamel_0_17_21-src = pkgs.fetchhg {
        hash = ruamel_0_17_21-hash;
        rev = "0.17.21";
        url = "http://hg.code.sf.net/p/ruamel-yaml/code";
      };
      ruamel_0_17_21-src-by-overriding = ruamel_0_18_14-src.overrideAttrs {
        hash = ruamel_0_17_21-hash;
        rev = "0.17.21";
      };
    in
    {
      hash-outputHash-equivalence = {
        expected = ruamel_0_17_21-hash;
        expr = ruamel_0_17_21-src.outputHash;
      };

      hash-overridability-drvPath = {
        expected = [
          true
          ruamel_0_17_21-src.drvPath
        ];

        expr = [
          (lib.isString ruamel_0_17_21-src-by-overriding.drvPath)
          ruamel_0_17_21-src-by-overriding.drvPath
        ];
      };

      hash-overridability-outPath = {
        expected = [
          true
          ruamel_0_17_21-src.outPath
        ];

        expr = [
          (lib.isString ruamel_0_17_21-src-by-overriding.outPath)
          ruamel_0_17_21-src-by-overriding.outPath
        ];
      };

      hash-overridability-outputHash = {
        expected = ruamel_0_17_21-hash;
        expr = ruamel_0_17_21-src-by-overriding.outputHash;
      };
    };

  tests-go =
    let
      pet_0_3_4 = pkgs.buildGoModule rec {
        pname = "pet";
        version = "0.3.4";

        src = pkgs.fetchFromGitHub {
          owner = "knqyf263";
          repo = "pet";
          rev = "v${version}";
          hash = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
        };

        vendorHash = "sha256-ciBIR+a1oaYH+H1PcC8cD8ncfJczk1IiJ8iYNM+R6aA=";

        meta = {
          description = "Simple command-line snippet manager, written in Go";
          homepage = "https://github.com/knqyf263/pet";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ kalbasit ];
        };
      };

      pet_0_4_0 = pkgs.buildGoModule rec {
        pname = "pet";
        version = "0.4.0";

        src = pkgs.fetchFromGitHub {
          owner = "knqyf263";
          repo = "pet";
          rev = "v${version}";
          hash = "sha256-gVTpzmXekQxGMucDKskGi+e+34nJwwsXwvQTjRO6Gdg=";
        };

        vendorHash = "sha256-dUvp7FEW09V0xMuhewPGw3TuAic/sD7xyXEYviZ2Ivs=";

        meta = {
          description = "Simple command-line snippet manager, written in Go";
          homepage = "https://github.com/knqyf263/pet";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ kalbasit ];
        };
      };

      pet_0_4_0-overridden = pet_0_3_4.overrideAttrs (
        finalAttrs: previousAttrs: {
          version = "0.4.0";

          src = pkgs.fetchFromGitHub {
            inherit (previousAttrs.src) owner repo;
            rev = "v${finalAttrs.version}";
            hash = "sha256-gVTpzmXekQxGMucDKskGi+e+34nJwwsXwvQTjRO6Gdg=";
          };

          vendorHash = "sha256-dUvp7FEW09V0xMuhewPGw3TuAic/sD7xyXEYviZ2Ivs=";
        }
      );

      pet-foo = pet_0_3_4.overrideAttrs (
        finalAttrs: previousAttrs: {
          passthru = previousAttrs.passthru // {
            overrideModAttrs = lib.composeExtensions previousAttrs.passthru.overrideModAttrs (
              finalModAttrs: previousModAttrs: {
                FOO = "foo";
              }
            );
          };
        }
      );

      pet-vendored = pet-foo.overrideAttrs { vendorHash = null; };
    in
    {
      buildGoModule-goModules-overrideAttrs = {
        expected = "foo";
        expr = pet-foo.goModules.FOO;
      };

      buildGoModule-goModules-overrideAttrs-vendored = {
        expected = true;
        expr = lib.isString pet-vendored.drvPath;
      };

      buildGoModule-overrideAttrs =
        let
          getComparingAttrs = p: {
            inherit (p)
              drvPath
              name
              pname
              version
              vendorHash
              ;

            goModules = {
              inherit (p.goModules)
                drvPath
                name
                outPath
                ;
            };
          };
        in
        {
          expected = getComparingAttrs pet_0_4_0;
          expr = getComparingAttrs pet_0_4_0-overridden;
        };
    };

  tests-python =
    let
      package-stub = pkgs.python3Packages.callPackage (
        {
          buildPythonPackage,
          emptyDirectory,
        }:
        buildPythonPackage {
          pname = "python-package-stub";
          version = "0.1.0";
          src = emptyDirectory;
          pyproject = true;
        }
      ) { };

      package-stub-gcc = package-stub.override (previousArgs: {
        buildPythonPackage = previousArgs.buildPythonPackage.override {
          stdenv = pkgs.gccStdenv;
        };
      });
      package-stub-clang = package-stub-gcc.override (previousArgs: {
        buildPythonPackage = previousArgs.buildPythonPackage.override {
          stdenv = pkgs.clangStdenv;
        };
      });
      package-stub-libcxx = package-stub-clang.override (previousArgs: {
        buildPythonPackage = previousArgs.buildPythonPackage.override {
          stdenv = pkgs.libcxxStdenv;
        };
      });

      applyOverridePythonAttrs =
        p:
        p.overridePythonAttrs (previousAttrs: {
          overridePythonAttrsFlag = previousAttrs.overridePythonAttrsFlag or 0 + 1;
        });
      applyOverridePythonAttrsFP =
        p:
        p.overridePythonAttrs (
          finalAttrs: previousAttrs: {
            overridePythonAttrsFlag = previousAttrs.overridePythonAttrsFlag or 0 + 1;
            overridePythonAttrsFlagP1 = finalAttrs.overridePythonAttrsFlag + 1;
          }
        );
      overrideAttrsFooBar =
        drv:
        drv.overrideAttrs (
          finalAttrs: previousAttrs: {
            BAR = finalAttrs.FOO;
            FOO = "a";
          }
        );
    in
    {
      buildPythonPackage-override-clangStdenv = {
        expected = pkgs.clangStdenv;
        expr = package-stub-clang.stdenv;
      };

      buildPythonPackage-override-gccStdenv = {
        expected = pkgs.gccStdenv;
        expr = package-stub-gcc.stdenv;
      };

      buildPythonPackage-override-libcxxStdenv = {
        expected = pkgs.libcxxStdenv;
        expr = package-stub-libcxx.stdenv;
      };

      chain-of-overrides = rec {
        expected = lib.genAttrs [ "a" "b" "c" "d" ] lib.id;

        expr = lib.pipe package-stub [
          (p: p.overrideAttrs { inherit (expected) a; })
          (p: p.overridePythonAttrs { inherit (expected) b; })
          (p: p.overrideAttrs { inherit (expected) c; })
          (p: p.overridePythonAttrs { inherit (expected) d; })
          (builtins.intersectAttrs expected)
        ];
      };

      overrideAttrs-overridePythonAttrs-test-commutation = {
        expected = applyOverridePythonAttrs (overrideAttrsFooBar package-stub);
        expr = overrideAttrsFooBar (applyOverridePythonAttrs package-stub);
      };

      overrideAttrs-overridePythonAttrs-test-overrideAttrs = {
        expected = {
          BAR = "a";
          FOO = "a";
        };

        expr = {
          inherit (applyOverridePythonAttrs (overrideAttrsFooBar package-stub))
            FOO
            BAR
            ;
        };
      };

      overrideAttrs-overridePythonAttrs-test-overridePythonAttrs = {
        expected = true;
        expr = (applyOverridePythonAttrs (overrideAttrsFooBar package-stub)) ? overridePythonAttrsFlag;
      };

      overridePythonAttrs = {
        expected = 1;
        expr = (applyOverridePythonAttrs package-stub).overridePythonAttrsFlag;
      };

      overridePythonAttrs-finalAttrs = {
        expected = {
          overridePythonAttrsFlag = 1;
          overridePythonAttrsFlagP1 = 2;
        };

        expr = {
          inherit (applyOverridePythonAttrsFP package-stub)
            overridePythonAttrsFlag
            overridePythonAttrsFlagP1
            ;
        };
      };

      overridePythonAttrs-nested = {
        expected = 2;
        expr = (applyOverridePythonAttrs (applyOverridePythonAttrs package-stub)).overridePythonAttrsFlag;
      };

      overridePythonAttrs-plain = {
        expected = 0;
        expr = (package-stub.overridePythonAttrs { overridePythonAttrsFlag = 0; }).overridePythonAttrsFlag;
      };
    };

in

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  buildCommand = ''
    touch $out
    for testName in "''${!testResults[@]}"; do
      if [[ -n "''${testResults[$testName]}" ]]; then
        echo "$testName success"
      else
        echo "$testName fail"
      fi
    done
  ''
  + lib.optionalString (lib.any (v: !v) (lib.attrValues finalAttrs.testResults)) ''
    {
      echo "ERROR: tests.overriding: Encountering failed tests."
      for testName in "''${!testResults[@]}"; do
        if [[ -z "''${testResults[$testName]}" ]]; then
          echo "- $testName"
        fi
      done
      echo "To inspect the expected and actual result, "
      echo '  evaluate `tests.overriding.tests.''${testName}`.'
    } >&2
    exit 1
  '';

  name = "test-overriding";
  testResults = lib.mapAttrs (testName: test: test.expr == test.expected) finalAttrs.passthru.tests;

  passthru = {
    inherit tests;
    failures = lib.runTests (finalAttrs.passthru.tests // { tests = lib.attrNames tests; });
  };
})
