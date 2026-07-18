{
  lib,
  stdenv,
  bintools,
  debian-devscripts,
  hello,
  runCommand,
  runCommandCC,
  runCommandWith,
  writeText,
}:

let
  # writeCBin from trivial-builders won't let us choose
  # our own stdenv
  writeCBinWithStdenv =
    codePath: stdenv': env:
    runCommandWith
      {
        derivationArgs = {
          inherit codePath;
          allowSubstitutes = false;
          preferLocalBuild = true;
        }
        // env;

        name = "test-bin";
        stdenv = stdenv';
      }
      ''
        [ -n "$postConfigure" ] && eval "$postConfigure"
        [ -n "$preBuild" ] && eval "$preBuild"
        n=$out/bin/test-bin
        mkdir -p "$(dirname "$n")"
        cp "$codePath" .
        NIX_DEBUG=1 $CC -x ''${TEST_SOURCE_LANG:-c} "$(basename $codePath)" -O1 $TEST_EXTRA_FLAGS -o "$n"
      '';

  f1exampleWithStdEnv = writeCBinWithStdenv ./fortify1-example.c;
  f2exampleWithStdEnv = writeCBinWithStdenv ./fortify2-example.c;
  f3exampleWithStdEnv = writeCBinWithStdenv ./fortify3-example.c;

  flexArrF2ExampleWithStdEnv = writeCBinWithStdenv ./flex-arrays-fortify-example.c;

  # we don't really have a reliable property for testing for
  # libstdc++ we'll just have to check for the absence of libcxx
  checkGlibcxxassertionsWithStdEnv =
    expectDefined: stdenv': derivationArgs:
    brokenIf (stdenv.cc.libcxx != null) (
      writeCBinWithStdenv
        (writeText "main.cpp" ''
          #if${if expectDefined then "n" else ""}def _GLIBCXX_ASSERTIONS
          #error "Expected _GLIBCXX_ASSERTIONS to be ${if expectDefined then "" else "un"}defined"
          #endif
          int main() {}
        '')
        stdenv'
        (
          derivationArgs
          // {
            env = (derivationArgs.env or { }) // {
              TEST_SOURCE_LANG = derivationArgs.env.TEST_SOURCE_LANG or "c++";
            };
          }
        )
    );

  checkLibcxxHardeningWithStdEnv =
    expectValue: stdenv': env:
    brokenIf (stdenv.cc.libcxx == null) (
      writeCBinWithStdenv
        (writeText "main.cpp" (
          ''
            #include <limits>
            #ifndef _LIBCPP_HARDENING_MODE
            #error "Expected _LIBCPP_HARDENING_MODE to be defined"
            #endif
            #ifndef ${expectValue}
            #error "Expected ${expectValue} to be defined"
            #endif

            #if _LIBCPP_HARDENING_MODE != ${expectValue}
            #error "Expected _LIBCPP_HARDENING_MODE to equal ${expectValue}"
            #endif
          ''
          + ''
            int main() {}
          ''
        ))
        stdenv'
        (
          env
          // {
            env = (env.env or { }) // {
              TEST_SOURCE_LANG = env.env.TEST_SOURCE_LANG or "c++";
            };
          }
        )
    );

  # for when we need a slightly more complicated program
  helloWithStdEnv =
    stdenv': env:
    (hello.override { stdenv = stdenv'; }).overrideAttrs (
      {
        preBuild = ''
          export CFLAGS="$TEST_EXTRA_FLAGS"
        '';

        postFixup = ''
          cp $out/bin/hello $out/bin/test-bin
        '';

        NIX_DEBUG = "1";
      }
      // env
    );

  stdenvUnsupport =
    additionalUnsupported:
    stdenv.override {
      allowedRequisites = null;

      cc = stdenv.cc.override {
        cc = (
          lib.extendDerivation true rec {
            hardeningUnsupportedFlags =
              (
                if stdenv.cc.cc ? hardeningUnsupportedFlagsByTargetPlatform then
                  stdenv.cc.cc.hardeningUnsupportedFlagsByTargetPlatform stdenv.targetPlatform
                else
                  (stdenv.cc.cc.hardeningUnsupportedFlags or [ ])
              )
              ++ additionalUnsupported;

            # this is ugly - have to cross-reference from
            # hardeningUnsupportedFlagsByTargetPlatform to hardeningUnsupportedFlags
            # because the finalAttrs mechanism that hardeningUnsupportedFlagsByTargetPlatform
            # implementations use to do this won't work with lib.extendDerivation.
            # but it's simplified by the fact that targetPlatform is already fixed
            # at this point.
            hardeningUnsupportedFlagsByTargetPlatform = _: hardeningUnsupportedFlags;
          } stdenv.cc.cc
        );
      };
    };

  checkTestBin =
    testBin:
    {
      expectFailure ? false,
      # can only test flags that are detectable by hardening-check
      ignoreBindNow ? true,
      ignoreFortify ? true,
      ignorePie ? true,
      ignoreRelRO ? true,
      ignoreStackClashProtection ? true,
      ignoreStackProtector ? true,
    }:
    let
      stackClashStr = "Stack clash protection: yes";
      expectFailureClause = lib.optionalString expectFailure " && echo 'ERROR: Expected hardening-check to fail, but it passed!' >&2 && false";
    in
    runCommandCC "check-test-bin"
      {
        nativeBuildInputs = [ debian-devscripts ];
        buildInputs = [ testBin ];

        meta = {
          platforms =
            if ignoreStackClashProtection then
              lib.platforms.linux # ELF-reliant
            else
              [ "x86_64-linux" ]; # stackclashprotection test looks for x86-specific instructions

          # musl implementation of fortify undetectable by this means even if present,
          # static similarly
          broken = (stdenv.hostPlatform.isMusl || stdenv.hostPlatform.isStatic) && !ignoreFortify;
        };
      }
      (
        ''
          if ${lib.optionalString (!expectFailure) "!"} {
            hardening-check --nocfprotection --nobranchprotection \
              ${lib.optionalString ignoreBindNow "--nobindnow"} \
              ${lib.optionalString ignoreFortify "--nofortify"} \
              ${lib.optionalString ignorePie "--nopie"} \
              ${lib.optionalString ignoreRelRO "--norelro"} \
              ${lib.optionalString ignoreStackProtector "--nostackprotector"} \
              $(PATH=$HOST_PATH type -P test-bin) | tee $out
        ''
        + lib.optionalString (!ignoreStackClashProtection) ''
          # stack clash protection doesn't actually affect the exit code of
          # hardening-check (likely authors think false negatives too common)
          { grep -F '${stackClashStr}' $out || { echo "Didn't find '${stackClashStr}' in output" && false ;} ;}
        ''
        + ''
          } ; then
        ''
        + lib.optionalString expectFailure ''
          echo 'ERROR: Expected hardening-check to fail, but it passed!' >&2
        ''
        + ''
            exit 2
          fi
        ''
      );

  nameDrvAfterAttrName = builtins.mapAttrs (
    name: drv:
    drv.overrideAttrs (_: {
      name = "test-${name}";
    })
  );

  fortifyExecTest = fortifyExecTestFull true "012345 7" "0123456 7";

  # returning a specific exit code when aborting due to a fortify
  # check isn't mandated. so it's better to just ensure that a
  # nonzero exit code is returned when we go a single byte beyond
  # the buffer, with the example programs being designed to be
  # unlikely to genuinely segfault for such a small overflow.
  fortifyExecTestFull =
    expectProtection: saturatedArgs: oneTooFarArgs: testBin:
    runCommand "exec-test"
      {
        buildInputs = [
          testBin
        ];

        meta.broken = !(stdenv.buildPlatform.canExecute stdenv.hostPlatform);
      }
      ''
        (
          export PATH=$HOST_PATH
          echo "Saturated buffer:" # check program isn't completly broken
          test-bin ${saturatedArgs}
          echo "One byte too far:" # overflow byte being the null terminator?
          (
            ${if expectProtection then "!" else ""} test-bin ${oneTooFarArgs}
          ) || (
            echo 'Expected ${if expectProtection then "failure" else "success"}, but ${
              if expectProtection then "succeeded" else "failed"
            }!' && exit 1
          )
        )
        echo "Expected behaviour observed"
        touch $out
      '';

  brokenIf =
    cond: drv:
    if cond then
      drv.overrideAttrs (old: {
        meta = old.meta or { } // {
          broken = true;
        };
      })
    else
      drv;
  overridePlatforms =
    platforms: drv:
    drv.overrideAttrs (old: {
      meta = old.meta or { } // {
        inherit platforms;
      };
    });

  instructionPresenceTest =
    label: mnemonicPattern: testBin: expectFailure:
    runCommand "${label}-instr-test"
      {
        nativeBuildInputs = [
          bintools
        ];

        buildInputs = [
          testBin
        ];
      }
      ''
        touch $out
        if $OBJDUMP -d \
          -j .text \
          --no-addresses \
          --no-show-raw-insn \
          "$(PATH=$HOST_PATH type -P test-bin)" \
          | grep -E '${mnemonicPattern}' > /dev/null ; then
          echo "Found ${label} instructions" >&2
          ${lib.optionalString expectFailure "exit 1"}
        else
          echo "Did not find ${label} instructions" >&2
          ${lib.optionalString (!expectFailure) "exit 1"}
        fi
      '';

  pacRetTest =
    testBin: expectFailure:
    overridePlatforms [ "aarch64-linux" ] (
      instructionPresenceTest "pacret" "\\bpaciasp\\b" testBin expectFailure
    );

  elfNoteTest =
    label: pattern: testBin: expectFailure:
    runCommand "${label}-elf-note-test"
      {
        nativeBuildInputs = [
          bintools
        ];

        buildInputs = [
          testBin
        ];
      }
      ''
        touch $out
        if $READELF -n "$(PATH=$HOST_PATH type -P test-bin)" \
          | grep -E '${pattern}' > /dev/null ; then
          echo "Found ${label} note" >&2
          ${lib.optionalString expectFailure "exit 1"}
        else
          echo "Did not find ${label} note" >&2
          ${lib.optionalString (!expectFailure) "exit 1"}
        fi
      '';

  shadowStackTest =
    testBin: expectFailure:
    brokenIf stdenv.hostPlatform.isMusl (
      overridePlatforms [ "x86_64-linux" ] (elfNoteTest "shadowstack" "\\bSHSTK\\b" testBin expectFailure)
    );

in
nameDrvAfterAttrName (
  {
    bindNowExplicitDisabled =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningDisable = [ "bindnow" ];
        })
        {
          expectFailure = true;
          ignoreBindNow = false;
        };

    bindNowExplicitEnabled = brokenIf stdenv.hostPlatform.isStatic (
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningEnable = [ "bindnow" ];
        })
        {
          ignoreBindNow = false;
        }
    );

    # current implementation doesn't force-disable fortify if
    # command-line enables it even if we use hardeningDisable.
    fortify1ExplicitDisabledCmdlineEnabled =
      checkTestBin
        (f1exampleWithStdEnv stdenv {
          postConfigure = ''
            export TEST_EXTRA_FLAGS='-D_FORTIFY_SOURCE=1'
          '';

          hardeningDisable = [ "fortify" ];
        })
        {
          ignoreFortify = false;
        };

    fortify1ExplicitDisabledCmdlineEnabledExecTest = fortifyExecTest (
      f1exampleWithStdEnv stdenv {
        postConfigure = ''
          export TEST_EXTRA_FLAGS='-D_FORTIFY_SOURCE=1'
        '';

        hardeningDisable = [ "fortify" ];
      }
    );

    # current implementation prevents the command-line from disabling
    # fortify if cc-wrapper is enabling it.
    fortify1ExplicitEnabledCmdlineDisabled =
      checkTestBin
        (f1exampleWithStdEnv stdenv {
          postConfigure = ''
            export TEST_EXTRA_FLAGS='-D_FORTIFY_SOURCE=0'
          '';

          hardeningEnable = [ "fortify" ];
        })
        {
          expectFailure = false;
          ignoreFortify = false;
        };

    fortify1ExplicitEnabledCmdlineDisabledNoWarn = f1exampleWithStdEnv stdenv {
      postConfigure = ''
        export TEST_EXTRA_FLAGS='-D_FORTIFY_SOURCE=0 -Werror'
      '';

      hardeningEnable = [ "fortify" ];
    };

    fortify1ExplicitEnabledExecTest = fortifyExecTest (
      f1exampleWithStdEnv stdenv {
        hardeningEnable = [ "fortify" ];
      }
    );

    fortify3EnabledEnvEnablesFortify1 =
      checkTestBin
        (f1exampleWithStdEnv stdenv {
          postConfigure = ''
            export NIX_HARDENING_ENABLE="fortify3"
          '';

          hardeningDisable = [
            "fortify"
            "fortify3"
          ];
        })
        {
          ignoreFortify = false;
        };

    fortify3EnabledEnvEnablesFortify1ExecTest = fortifyExecTest (
      f1exampleWithStdEnv stdenv {
        postConfigure = ''
          export NIX_HARDENING_ENABLE="fortify3"
        '';

        hardeningDisable = [
          "fortify"
          "fortify3"
        ];
      }
    );

    fortify3ExplicitDisabled =
      checkTestBin
        (f3exampleWithStdEnv stdenv {
          hardeningDisable = [ "fortify3" ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    fortify3ExplicitDisabledDoesntDisableFortify =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningDisable = [ "fortify3" ];
          hardeningEnable = [ "fortify" ];
        })
        {
          ignoreFortify = false;
        };

    fortify3ExplicitEnabled = brokenIf (!stdenv.cc.isGNU || lib.versionOlder stdenv.cc.version "12") (
      checkTestBin
        (f3exampleWithStdEnv stdenv {
          hardeningEnable = [ "fortify3" ];
        })
        {
          ignoreFortify = false;
        }
    );

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    fortify3ExplicitEnabledExecTest =
      brokenIf (stdenv.hostPlatform.isMusl || !stdenv.cc.isGNU || lib.versionOlder stdenv.cc.version "12")
        (
          fortifyExecTest (
            f3exampleWithStdEnv stdenv {
              hardeningEnable = [ "fortify3" ];
            }
          )
        );

    fortify3StdenvUnsupp =
      checkTestBin
        (f3exampleWithStdEnv (stdenvUnsupport [ "fortify3" ]) {
          hardeningEnable = [ "fortify3" ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    fortify3StdenvUnsuppDoesntUnsuppFortify1 =
      checkTestBin
        (f1exampleWithStdEnv (stdenvUnsupport [ "fortify3" ]) {
          hardeningEnable = [ "fortify" ];
        })
        {
          ignoreFortify = false;
        };

    fortify3StdenvUnsuppDoesntUnsuppFortify1ExecTest = fortifyExecTest (
      f1exampleWithStdEnv (stdenvUnsupport [ "fortify3" ]) {
        hardeningEnable = [ "fortify" ];
      }
    );

    fortifyEnabledEnvDoesntEnableFortify3 =
      checkTestBin
        (f3exampleWithStdEnv stdenv {
          postConfigure = ''
            export NIX_HARDENING_ENABLE="fortify"
          '';

          hardeningDisable = [
            "fortify"
            "fortify3"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    fortifyExplicitDisabled =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningDisable = [ "fortify" ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    fortifyExplicitDisabledDisablesFortify3 =
      checkTestBin
        (f3exampleWithStdEnv stdenv {
          hardeningDisable = [ "fortify" ];
          hardeningEnable = [ "fortify3" ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    fortifyExplicitEnabled = (
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningEnable = [ "fortify" ];
        })
        {
          ignoreFortify = false;
        }
    );

    # musl implementation is effectively FORTIFY_SOURCE=1-only,
    fortifyExplicitEnabledExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTest (
        f2exampleWithStdEnv stdenv {
          hardeningEnable = [ "fortify" ];
        }
      )
    );

    # most flags can't be "unsupported" by compiler alone and
    # binutils doesn't have an accessible hardeningUnsupportedFlags
    # mechanism, so can only test a couple of flags through altered
    # stdenv trickery
    fortifyStdenvUnsupp =
      checkTestBin
        (f2exampleWithStdEnv
          (stdenvUnsupport [
            "fortify"
            "fortify3"
          ])
          {
            hardeningEnable = [ "fortify" ];
          }
        )
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    fortifyStdenvUnsuppUnsupportsFortify3 =
      checkTestBin
        (f3exampleWithStdEnv (stdenvUnsupport [ "fortify" ]) {
          hardeningEnable = [ "fortify3" ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    glibcxxassertionsExplicitDisabled = checkGlibcxxassertionsWithStdEnv false stdenv {
      hardeningDisable = [ "glibcxxassertions" ];
    };

    glibcxxassertionsExplicitEnabled = checkGlibcxxassertionsWithStdEnv true stdenv {
      hardeningEnable = [ "glibcxxassertions" ];
    };

    glibcxxassertionsStdenvUnsupp =
      checkGlibcxxassertionsWithStdEnv false (stdenvUnsupport [ "glibcxxassertions" ])
        {
          hardeningEnable = [ "glibcxxassertions" ];
        };

    lchExtensiveEnabledEnv = checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_EXTENSIVE" stdenv {
      postConfigure = ''
        export NIX_HARDENING_ENABLE="libcxxhardeningextensive"
      '';

      hardeningDisable = [
        "libcxxhardeningfast"
        "libcxxhardeningextensive"
      ];
    };

    lchExtensiveExplicitDisabledDoesntDisableLchFast =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_FAST" stdenv
        {
          hardeningDisable = [ "libcxxhardeningextensive" ];
          hardeningEnable = [ "libcxxhardeningfast" ];
        };

    lchExtensiveExplicitEnabled =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_EXTENSIVE" stdenv
        {
          hardeningEnable = [ "libcxxhardeningextensive" ];
        };

    lchExtensiveStdenvUnsuppDoesntUnsupportLchFast =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_FAST"
        (stdenvUnsupport [ "libcxxhardeningextensive" ])
        {
          hardeningEnable = [
            "libcxxhardeningfast"
            "libcxxhardeningextensive"
          ];
        };

    lchFastEnabledEnv = checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_FAST" stdenv {
      postConfigure = ''
        export NIX_HARDENING_ENABLE="libcxxhardeningfast"
      '';

      hardeningDisable = [
        "libcxxhardeningfast"
        "libcxxhardeningextensive"
      ];
    };

    lchFastExplicitDisabled = checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_NONE" stdenv {
      hardeningDisable = [ "libcxxhardeningfast" ];
    };

    lchFastExplicitDisabledDisablesLchExtensive =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_NONE" stdenv
        {
          hardeningDisable = [ "libcxxhardeningfast" ];
          hardeningEnable = [ "libcxxhardeningextensive" ];
        };

    lchFastExtensiveEnabledEnvResultsInLchExtensive =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_EXTENSIVE" stdenv
        {
          postConfigure = ''
            export NIX_HARDENING_ENABLE="libcxxhardeningextensive libcxxhardeningfast"
          '';

          hardeningDisable = [
            "libcxxhardeningfast"
            "libcxxhardeningextensive"
          ];
        };

    lchFastExtensiveExplicitDisabledDisablesBoth =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_NONE" stdenv
        {
          hardeningDisable = [
            "libcxxhardeningfast"
            "libcxxhardeningextensive"
          ];
        };

    lchFastExtensiveExplicitEnabledResultsInLchExtensive =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_EXTENSIVE" stdenv
        {
          hardeningEnable = [
            "libcxxhardeningfast"
            "libcxxhardeningextensive"
          ];
        };

    lchFastStdenvUnsupp =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_NONE"
        (stdenvUnsupport [ "libcxxhardeningfast" ])
        {
          hardeningEnable = [ "libcxxhardeningfast" ];
        };

    lchFastStdenvUnsuppUnsupportsLchExtensive =
      checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_NONE"
        (stdenvUnsupport [ "libcxxhardeningfast" ])
        {
          hardeningEnable = [ "libcxxhardeningextensive" ];
        };

    pacRetExplicitDisabled = pacRetTest (helloWithStdEnv stdenv {
      hardeningDisable = [ "pacret" ];
    }) true;

    pacRetExplicitEnabled = pacRetTest (helloWithStdEnv stdenv {
      hardeningEnable = [ "pacret" ];
    }) false;

    pieAlwaysEnabled = brokenIf stdenv.hostPlatform.isStatic (
      checkTestBin (f2exampleWithStdEnv stdenv { }) {
        ignorePie = false;
      }
    );

    # can't force-disable ("partial"?) relro
    relROExplicitDisabled = brokenIf true (
      checkTestBin
        (f2exampleWithStdEnv stdenv {
        })
        {
          expectFailure = true;
          ignoreRelRO = false;
        }
    );

    relROExplicitEnabled =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningEnable = [ "relro" ];
        })
        {
          ignoreRelRO = false;
        };

    sfa1EnabledEnvDoesntEnableSfa3 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          postConfigure = ''
            export NIX_HARDENING_ENABLE="fortify strictflexarrays1"
          '';

          hardeningDisable = [
            "strictflexarrays1"
            "strictflexarrays3"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    sfa1StdenvUnsupp =
      checkTestBin
        (flexArrF2ExampleWithStdEnv
          (stdenvUnsupport [
            "strictflexarrays1"
            "strictflexarrays3"
          ])
          {
            env = {
              TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
            };

            hardeningEnable = [
              "fortify"
              "strictflexarrays1"
            ];
          }
        )
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    sfa1StdenvUnsuppUnsupportsSfa3 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv (stdenvUnsupport [ "strictflexarrays1" ]) {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa1explicitDisabled = brokenIf stdenv.hostPlatform.isMusl (
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningDisable = [ "strictflexarrays1" ];
          hardeningEnable = [ "fortify" ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        }
    );

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa1explicitDisabledDisablesSfa3 = brokenIf stdenv.hostPlatform.isMusl (
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningDisable = [ "strictflexarrays1" ];

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        }
    );

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa1explicitDisabledDisablesSfa3ExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull false "''" "0" (
        flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningDisable = [ "strictflexarrays1" ];

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        }
      )
    );

    sfa1explicitDisabledExecTest = fortifyExecTestFull false "012345" "0123456" (
      flexArrF2ExampleWithStdEnv stdenv {
        env = {
          TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
        };

        hardeningDisable = [ "strictflexarrays1" ];
        hardeningEnable = [ "fortify" ];
      }
    );

    sfa1explicitEnabled =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        })
        {
          ignoreFortify = false;
        };

    sfa1explicitEnabledDoesntProtectDefLen1 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa1explicitEnabledDoesntProtectDefLen1ExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull false "''" "0" (
        flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        }
      )
    );

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa1explicitEnabledExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull true "012345" "0123456" (
        flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        }
      )
    );

    sfa3EnabledEnvEnablesSfa1 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          postConfigure = ''
            export NIX_HARDENING_ENABLE="fortify strictflexarrays3"
          '';

          hardeningDisable = [
            "strictflexarrays1"
            "strictflexarrays3"
          ];
        })
        {
          ignoreFortify = false;
        };

    sfa3EnabledEnvEnablesSfa1ExecTest = fortifyExecTestFull true "012345" "0123456" (
      f1exampleWithStdEnv stdenv {
        env = {
          TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
        };

        postConfigure = ''
          export NIX_HARDENING_ENABLE="fortify strictflexarrays3"
        '';

        hardeningDisable = [
          "strictflexarrays1"
          "strictflexarrays3"
        ];
      }
    );

    sfa3StdenvUnsupp =
      checkTestBin
        (flexArrF2ExampleWithStdEnv (stdenvUnsupport [ "strictflexarrays3" ]) {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    sfa3StdenvUnsuppDoesntUnsuppSfa1 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv (stdenvUnsupport [ "strictflexarrays3" ]) {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        })
        {
          ignoreFortify = false;
        };

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa3StdenvUnsuppDoesntUnsuppSfa1ExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull true "012345" "0123456" (
        flexArrF2ExampleWithStdEnv (stdenvUnsupport [ "strictflexarrays3" ]) {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        }
      )
    );

    sfa3explicitDisabledDoesntDisableSfa1 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningDisable = [ "strictflexarrays3" ];

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        })
        {
          ignoreFortify = false;
        };

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa3explicitDisabledDoesntDisableSfa1ExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull true "012345" "0123456" (
        flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=7";
          };

          hardeningDisable = [ "strictflexarrays3" ];

          hardeningEnable = [
            "fortify"
            "strictflexarrays1"
          ];
        }
      )
    );

    sfa3explicitEnabledDoesntProtectCorrectFlex =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        })
        {
          expectFailure = true;
          ignoreFortify = false;
        };

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa3explicitEnabledDoesntProtectCorrectFlexExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull false "" "0" (
        flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        }
      )
    );

    sfa3explicitEnabledProtectsDefLen1 =
      checkTestBin
        (flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        })
        {
          ignoreFortify = false;
        };

    # musl implementation is effectively FORTIFY_SOURCE=1-only
    sfa3explicitEnabledProtectsDefLen1ExecTest = brokenIf stdenv.hostPlatform.isMusl (
      fortifyExecTestFull true "''" "0" (
        flexArrF2ExampleWithStdEnv stdenv {
          env = {
            TEST_EXTRA_FLAGS = "-DBUFFER_DEF_SIZE=1";
          };

          hardeningEnable = [
            "fortify"
            "strictflexarrays3"
          ];
        }
      )
    );

    shadowStackExplicitDisabled = shadowStackTest (f1exampleWithStdEnv stdenv {
      hardeningDisable = [ "shadowstack" ];
    }) true;

    shadowStackExplicitEnabled = shadowStackTest (f1exampleWithStdEnv stdenv {
      hardeningEnable = [ "shadowstack" ];
    }) false;

    stackClashProtectionExplicitDisabled =
      checkTestBin
        (helloWithStdEnv stdenv {
          hardeningDisable = [ "stackclashprotection" ];
        })
        {
          expectFailure = true;
          ignoreStackClashProtection = false;
        };

    # protection patterns generated by clang not detectable?
    stackClashProtectionExplicitEnabled = brokenIf stdenv.cc.isClang (
      checkTestBin
        (helloWithStdEnv stdenv {
          hardeningEnable = [ "stackclashprotection" ];
        })
        {
          ignoreStackClashProtection = false;
        }
    );

    stackClashProtectionStdenvUnsupp =
      checkTestBin
        (helloWithStdEnv (stdenvUnsupport [ "stackclashprotection" ]) {
          hardeningEnable = [ "stackclashprotection" ];
        })
        {
          expectFailure = true;
          ignoreStackClashProtection = false;
        };

    stackProtectorExplicitDisabled =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningDisable = [ "stackprotector" ];
        })
        {
          expectFailure = true;
          ignoreStackProtector = false;
        };

    stackProtectorExplicitEnabled = brokenIf stdenv.hostPlatform.isStatic (
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          hardeningEnable = [ "stackprotector" ];
        })
        {
          ignoreStackProtector = false;
        }
    );

    stackProtectorRedisabledEnv =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          postConfigure = ''
            export NIX_HARDENING_ENABLE=""
          '';

          hardeningEnable = [ "stackprotector" ];
        })
        {
          expectFailure = true;
          ignoreStackProtector = false;
        };

    # NIX_HARDENING_ENABLE set in the shell overrides hardeningDisable
    # and hardeningEnable
    stackProtectorReenabledEnv =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          postConfigure = ''
            export NIX_HARDENING_ENABLE="stackprotector"
          '';

          hardeningDisable = [ "stackprotector" ];
        })
        {
          ignoreStackProtector = false;
        };

    stackProtectorReenabledFromAllEnv =
      checkTestBin
        (f2exampleWithStdEnv stdenv {
          postConfigure = ''
            export NIX_HARDENING_ENABLE="stackprotector"
          '';

          hardeningDisable = [ "all" ];
        })
        {
          ignoreStackProtector = false;
        };

    stackProtectorStdenvUnsupp =
      checkTestBin
        (f2exampleWithStdEnv (stdenvUnsupport [ "stackprotector" ]) {
          hardeningEnable = [ "stackprotector" ];
        })
        {
          expectFailure = true;
          ignoreStackProtector = false;
        };

    # NIX_HARDENING_ENABLE can't enable an unsupported feature
    stackProtectorUnsupportedEnabledEnv =
      checkTestBin
        (f2exampleWithStdEnv (stdenvUnsupport [ "stackprotector" ]) {
          postConfigure = ''
            export NIX_HARDENING_ENABLE="stackprotector"
          '';
        })
        {
          expectFailure = true;
          ignoreStackProtector = false;
        };

  }
  // (
    let
      tb = f2exampleWithStdEnv stdenv {
        hardeningDisable = [ "all" ];

        hardeningEnable = [
          "fortify"
        ];
      };
    in
    {

      allExplicitDisabledBindNow = checkTestBin tb {
        expectFailure = true;
        ignoreBindNow = false;
      };

      allExplicitDisabledFortify = checkTestBin tb {
        expectFailure = true;
        ignoreFortify = false;
      };

      allExplicitDisabledGlibcxxAssertions = checkGlibcxxassertionsWithStdEnv false stdenv {
        hardeningDisable = [ "all" ];
      };

      allExplicitDisabledLibcxxHardening =
        checkLibcxxHardeningWithStdEnv "_LIBCPP_HARDENING_MODE_NONE" stdenv
          {
            hardeningDisable = [ "all" ];
          };

      allExplicitDisabledPacRet = pacRetTest (helloWithStdEnv stdenv {
        hardeningDisable = [ "all" ];
      }) true;

      # can't force-disable ("partial"?) relro
      allExplicitDisabledRelRO = brokenIf true (
        checkTestBin tb {
          expectFailure = true;
          ignoreRelRO = false;
        }
      );

      allExplicitDisabledShadowStack = shadowStackTest (f1exampleWithStdEnv stdenv {
        hardeningDisable = [ "all" ];
      }) true;

      allExplicitDisabledStackClashProtection = checkTestBin tb {
        expectFailure = true;
        ignoreStackClashProtection = false;
      };

      allExplicitDisabledStackProtector = checkTestBin tb {
        expectFailure = true;
        ignoreStackProtector = false;
      };
    }
  )
)
