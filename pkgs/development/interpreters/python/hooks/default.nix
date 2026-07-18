self: dontUse:
with self;

let
  inherit (python) pythonOnBuildForHost;
  inherit (pkgs) runCommand;
  pythonInterpreter = pythonOnBuildForHost.interpreter;
  pythonSitePackages = python.sitePackages;
  pythonCheckInterpreter = python.interpreter;
  setuppy = ../run_setup.py;
in
{
  condaInstallHook = callPackage (
    {
      gnutar,
      lbzip2,
      makePythonHook,
    }:
    makePythonHook {
      propagatedBuildInputs = [
        gnutar
        lbzip2
      ];

      name = "conda-install-hook";

      substitutions = {
        inherit pythonSitePackages;
      };
    } ./conda-install-hook.sh
  ) { };

  condaUnpackHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "conda-unpack-hook";
    } ./conda-unpack-hook.sh
  ) { };

  eggBuildHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "egg-build-hook.sh";
    } ./egg-build-hook.sh
  ) { };

  eggInstallHook = callPackage (
    { makePythonHook, setuptools }:
    makePythonHook {
      propagatedBuildInputs = [ setuptools ];
      name = "egg-install-hook.sh";

      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./egg-install-hook.sh
  ) { };

  eggUnpackHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "egg-unpack-hook.sh";
    } ./egg-unpack-hook.sh
  ) { };

  makePythonHook =
    let
      defaultArgs = {
        passthru.provides.setupHook = true;
      };
    in
    args: pkgs.makeSetupHook (lib.recursiveUpdate defaultArgs args);

  pipBuildHook = callPackage (
    {
      makePythonHook,
      pip,
      wheel,
    }:
    makePythonHook {
      propagatedBuildInputs = [
        pip
        wheel
      ];

      name = "pip-build-hook.sh";

      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./pip-build-hook.sh
  ) { };

  pipInstallHook = callPackage (
    { makePythonHook, pip }:
    makePythonHook {
      propagatedBuildInputs = [ pip ];
      name = "pip-install-hook";

      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
      };
    } ./pip-install-hook.sh
  ) { };

  pypaBuildHook =
    callPackage
      (
        {
          build,
          makePythonHook,
          wheel,
        }:
        makePythonHook {
          propagatedBuildInputs = [ wheel ];
          name = "pypa-build-hook.sh";

          substitutions = {
            inherit build;
          };

          # A test to ensure that this hook never propagates any of its dependencies
          #   into the build environment.
          # This prevents false positive alerts raised by catchConflictsHook.
          # Such conflicts don't happen within the standard nixpkgs python package
          #   set, but in downstream projects that build packages depending on other
          #   versions of this hook's dependencies.
          passthru.tests = callPackage ./pypa-build-hook-test.nix {
            inherit pythonOnBuildForHost;
          };
        } ./pypa-build-hook.sh
      )
      {
        inherit (pythonOnBuildForHost.pkgs) build;
      };

  pypaInstallHook =
    callPackage
      (
        { installer, makePythonHook }:
        makePythonHook {
          propagatedBuildInputs = [ installer ];
          name = "pypa-install-hook";

          substitutions = {
            inherit pythonInterpreter pythonSitePackages;
            python = python.interpreter;
          };
        } ./pypa-install-hook.sh
      )
      {
        inherit (pythonOnBuildForHost.pkgs) installer;
      };

  pyprojectVersionPatchHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "pyproject-version-patch-hook.sh";

      substitutions = {
        pythonInterpreter =
          (pythonOnBuildForHost.withPackages (ps: [
            ps.packaging
            ps.tomlkit
          ])).interpreter;

        script = ./pyproject-version-patch-hook.py;
      };

      meta = {
        maintainers = [ lib.maintainers.dotlambda ];
      };
    } ./pyproject-version-patch-hook.sh
  ) { };

  pytestCheckHook = callPackage (
    {
      makePythonHook,
      objprint,
      pytest,
      # For package tests
      testers,
    }:
    makePythonHook {
      propagatedBuildInputs = [ pytest ];
      name = "pytest-check-hook";

      substitutions = {
        inherit pythonCheckInterpreter;
      };

      passthru = {
        tests = {
          basic = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-basic-${previousPythonAttrs.pname}";
          });

          disabledTestPaths = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-disabledTestPaths-${previousPythonAttrs.pname}";

            disabledTestPaths = [
              "tests/test_basic.py"
            ]
            ++ previousPythonAttrs.disabledTestPaths or [ ];
          });

          disabledTestPaths-glob = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-disabledTestPaths-glob-${previousPythonAttrs.pname}";

            disabledTestPaths = [
              "tests/test_obj*.py"
            ]
            ++ previousPythonAttrs.disabledTestPaths or [ ];
          });

          disabledTestPaths-glob-nonexistent = testers.testBuildFailure (
            objprint.overridePythonAttrs (previousPythonAttrs: {
              pname = "test-pytestCheckHook-disabledTestPaths-glob-nonexistent-${previousPythonAttrs.pname}";

              disabledTestPaths = [
                "tests/test_foo*.py"
              ]
              ++ previousPythonAttrs.disabledTestPaths or [ ];
            })
          );

          disabledTestPaths-item = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-disabledTestPaths-item-${previousPythonAttrs.pname}";

            disabledTestPaths = [
              "tests/test_basic.py::TestBasic"
            ]
            ++ previousPythonAttrs.disabledTestPaths or [ ];
          });

          disabledTestPaths-nonexistent = testers.testBuildFailure (
            objprint.overridePythonAttrs (previousPythonAttrs: {
              pname = "test-pytestCheckHook-disabledTestPaths-nonexistent-${previousPythonAttrs.pname}";

              disabledTestPaths = [
                "tests/test_foo.py"
              ]
              ++ previousPythonAttrs.disabledTestPaths or [ ];
            })
          );

          disabledTests = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-disabledTests-${previousPythonAttrs.pname}";

            disabledTests = [
              "test_print"
            ]
            ++ previousPythonAttrs.disabledTests or [ ];
          });

          disabledTests-expression = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-disabledTests-expression-${previousPythonAttrs.pname}";
            __structuredAttrs = true;

            disabledTests = [
              "TestBasic and test_print"
              "test_str"
            ]
            ++ previousPythonAttrs.disabledTests or [ ];
          });

          enabledTestPaths = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTestPaths-${previousPythonAttrs.pname}";

            enabledTestPaths = [
              "tests/test_basic.py"
            ]
            ++ previousPythonAttrs.enabledTestPaths or [ ];
          });

          enabledTestPaths-dir = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTestPaths-dir-${previousPythonAttrs.pname}";

            enabledTestPaths = [
              "tests"
            ]
            ++ previousPythonAttrs.enabledTestPaths or [ ];
          });

          enabledTestPaths-dir-disabledTestPaths = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTestPaths-dir-disabledTestPaths-${previousPythonAttrs.pname}";

            disabledTestPaths = [
              "tests/test_basic.py"
            ]
            ++ previousPythonAttrs.disabledTestPaths or [ ];

            enabledTestPaths = [
              "tests"
            ]
            ++ previousPythonAttrs.enabledTestPaths or [ ];
          });

          enabledTestPaths-glob = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTestPaths-glob-${previousPythonAttrs.pname}";

            enabledTestPaths = [
              "tests/test_obj*.py"
            ]
            ++ previousPythonAttrs.enabledTestPaths or [ ];
          });

          enabledTestPaths-glob-nonexistent = testers.testBuildFailure (
            objprint.overridePythonAttrs (previousPythonAttrs: {
              pname = "test-pytestCheckHook-enabledTestPaths-glob-nonexistent-${previousPythonAttrs.pname}";

              enabledTestPaths = [
                "tests/test_foo*.py"
              ]
              ++ previousPythonAttrs.enabledTestPaths or [ ];
            })
          );

          enabledTestPaths-item = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTestPaths-item-${previousPythonAttrs.pname}";

            enabledTestPaths = [
              "tests/test_basic.py::TestBasic"
            ]
            ++ previousPythonAttrs.enabledTestPaths or [ ];
          });

          enabledTestPaths-nonexistent = testers.testBuildFailure (
            objprint.overridePythonAttrs (previousPythonAttrs: {
              pname = "test-pytestCheckHook-enabledTestPaths-nonexistent-${previousPythonAttrs.pname}";

              enabledTestPaths = [
                "tests/test_foo.py"
              ]
              ++ previousPythonAttrs.enabledTestPaths or [ ];
            })
          );

          enabledTests = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTests-${previousPythonAttrs.pname}";

            enabledTests = [
              "TestBasic"
            ]
            ++ previousPythonAttrs.disabledTests or [ ];
          });

          enabledTests-disabledTests = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTests-disabledTests-${previousPythonAttrs.pname}";

            disabledTests = [
              "test_print"
            ]
            ++ previousPythonAttrs.disabledTests or [ ];

            enabledTests = [
              "TestBasic"
            ]
            ++ previousPythonAttrs.disabledTests or [ ];
          });

          enabledTests-expression = objprint.overridePythonAttrs (previousPythonAttrs: {
            pname = "test-pytestCheckHook-enabledTests-expression-${previousPythonAttrs.pname}";
            __structuredAttrs = true;

            enabledTests = [
              "TestBasic and test_print"
              "test_str"
            ]
            ++ previousPythonAttrs.disabledTests or [ ];
          });
        };
      };
    } ./pytest-check-hook.sh
  ) { };

  pythonCatchConflictsHook = callPackage (
    { makePythonHook, setuptools }:
    makePythonHook {
      name = "python-catch-conflicts-hook";

      substitutions =
        let
          useLegacyHook = lib.versionOlder python.pythonVersion "3";
        in
        {
          inherit pythonInterpreter pythonSitePackages;

          catchConflicts =
            if useLegacyHook then
              ../catch_conflicts/catch_conflicts_py2.py
            else
              ../catch_conflicts/catch_conflicts.py;
        }
        // lib.optionalAttrs useLegacyHook {
          inherit setuptools;
        };

      passthru.tests = import ./python-catch-conflicts-hook-tests.nix {
        inherit pythonOnBuildForHost runCommand;
        inherit lib;
        inherit (pkgs) coreutils gnugrep writeShellScript;
      };
    } ./python-catch-conflicts-hook.sh
  ) { };

  pythonImportsCheckHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "python-imports-check-hook.sh";

      substitutions = {
        inherit pythonCheckInterpreter pythonSitePackages;
      };
    } ./python-imports-check-hook.sh
  ) { };

  pythonNamespacesHook = callPackage (
    { buildPackages, makePythonHook }:
    makePythonHook {
      name = "python-namespaces-hook.sh";

      substitutions = {
        inherit pythonSitePackages;
        inherit (buildPackages) findutils;
      };
    } ./python-namespaces-hook.sh
  ) { };

  pythonOutputDistHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "python-output-dist-hook";
    } ./python-output-dist-hook.sh
  ) { };

  pythonRecompileBytecodeHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "python-recompile-bytecode-hook";

      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
        bytecodeName = if isPy3k then "__pycache__" else "*.pyc";

        compileArgs = lib.concatStringsSep " " (
          [
            "-q"
            "-f"
            "-i -"
          ]
          ++ lib.optionals isPy3k [ "-j $NIX_BUILD_CORES" ]
        );
      };
    } ./python-recompile-bytecode-hook.sh
  ) { };

  pythonRelaxDepsHook = callPackage (
    { makePythonHook, wheel }:
    makePythonHook {
      name = "python-relax-deps-hook";

      substitutions = {
        inherit pythonInterpreter pythonSitePackages wheel;
      };
    } ./python-relax-deps-hook.sh
  ) { };

  pythonRemoveBinBytecodeHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "python-remove-bin-bytecode-hook";
    } ./python-remove-bin-bytecode-hook.sh
  ) { };

  pythonRemoveTestsDirHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "python-remove-tests-dir-hook";

      substitutions = {
        inherit pythonSitePackages;
      };
    } ./python-remove-tests-dir-hook.sh
  ) { };

  pythonRuntimeDepsCheckHook = callPackage (
    { makePythonHook, packaging }:
    makePythonHook {
      propagatedBuildInputs = [ packaging ];
      name = "python-runtime-deps-check-hook.sh";

      substitutions = {
        inherit pythonInterpreter pythonSitePackages;
        hook = ./python-runtime-deps-check-hook.py;
      };
    } ./python-runtime-deps-check-hook.sh
  ) { };

  setuptoolsBuildHook = callPackage (
    {
      makePythonHook,
      setuptools,
      wheel,
    }:
    makePythonHook {
      propagatedBuildInputs = [
        setuptools
        wheel
      ];

      name = "setuptools-build-hook";

      substitutions = {
        inherit pythonInterpreter setuppy;
        # python2.pkgs.setuptools does not support parallelism
        setuptools_has_parallel = setuptools != null && lib.versionAtLeast setuptools.version "69";
      };
    } ./setuptools-build-hook.sh
  ) { };

  sphinxHook = callPackage (
    { installShellFiles, makePythonHook }:
    makePythonHook {
      propagatedBuildInputs = [
        pythonOnBuildForHost.pkgs.sphinx
        installShellFiles
      ];

      name = "python${python.pythonVersion}-sphinx-hook";

      substitutions = {
        sphinxBuild = "${pythonOnBuildForHost.pkgs.sphinx}/bin/sphinx-build";
      };
    } ./sphinx-hook.sh
  ) { };

  stestrCheckHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      propagatedBuildInputs = [ stestr ];
      name = "stestr-check-hook";

      substitutions = {
        inherit pythonCheckInterpreter;
      };
    } ./stestr-check-hook.sh
  ) { };

  unittestCheckHook = callPackage (
    { makePythonHook }:
    makePythonHook {
      name = "unittest-check-hook";

      substitutions = {
        inherit pythonCheckInterpreter;
      };
    } ./unittest-check-hook.sh
  ) { };

  venvShellHook = disabledIf (!isPy3k) (
    callPackage (
      { ensureNewerSourcesForZipFilesHook, makePythonHook }:
      makePythonHook {
        propagatedBuildInputs = [ ensureNewerSourcesForZipFilesHook ];
        name = "venv-shell-hook";

        substitutions = {
          inherit pythonInterpreter;
        };
      } ./venv-shell-hook.sh
    ) { }
  );

  wheelUnpackHook = callPackage (
    { makePythonHook, wheel }:
    makePythonHook {
      propagatedBuildInputs = [ wheel ];
      name = "wheel-unpack-hook.sh";
    } ./wheel-unpack-hook.sh
  ) { };

  wrapPython = callPackage ../wrap-python.nix {
    inherit (pkgs.buildPackages) makeWrapper;
  };
}
