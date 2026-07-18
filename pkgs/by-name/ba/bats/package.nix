{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  # packages that use bats (for update testing)
  bash-preexec,
  bats,
  callPackages,
  coreutils,
  findutils,
  flock,
  gnugrep,
  hostname,
  kikit,
  locate-dominating-file,
  lsof,
  makeWrapper,
  ncurses,
  packcc,
  parallel,
  procps,
  resholve,
  runCommand,
  symlinkJoin,
  writeText,
  doInstallCheck ? true,
}:

resholve.mkDerivation (finalAttrs: {
  pname = "bats";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "bats-core";
    repo = "bats-core";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5VCkOzyaUOBW+HVVHDkH9oCWDI/MJW6yrLTQG60Ralk=";
  };

  installPhase = ''
    ./install.sh $out
  '';

  patchPhase = ''
    patchShebangs .
  '';

  solutions = {
    bats = {
      execer = [
        /*
          both blatant lies for expedience; these can certainly exec args
          they may be safe here, because they may always run things that
          are ultimately in libexec?
          TODO: handle parallel and flock in binlore/resholve
        */
        "cannot:${parallel}/bin/parallel"
        "cannot:${flock}/bin/flock"

        "cannot:libexec/bats-core/bats-preprocess"

        # these do exec, but other internal files
        "cannot:libexec/bats-core/bats-exec-file"
        "cannot:libexec/bats-core/bats-exec-suite"
        "cannot:libexec/bats-core/bats-gather-tests"

        "cannot:${procps}/bin/ps"
      ]
      ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
        # checked invocations for exec
        "cannot:${procps}/bin/pkill"
      ];

      fake = {
        external = [
          "greadlink"
          "shlock"
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          "pkill" # procps doesn't supply this on darwin
        ];
      };

      fix = {
        "$BATS_LIBDIR" = [ "lib" ];
        "$BATS_LIBEXEC" = [ "${placeholder "out"}/libexec/bats-core" ];
        "$BATS_ROOT" = [ "${placeholder "out"}" ];
      };

      inputs = [
        bash
        coreutils
        gnugrep
        ncurses
        findutils
        hostname
        parallel
        flock
        "lib/bats-core"
        "libexec/bats-core"
        procps
      ];

      interpreter = "${bash}/bin/bash";

      keep = {
        "$BATS_LINE_REFERENCE_FORMAT" = "comma_line";
        "$BATS_LOCKING_IMPLEMENTATION" = "${flock}/bin/flock";
        "$BATS_TEST_NAME" = true;
        "$interpolated_formatter" = true;
        "$interpolated_report_formatter" = true;
        "$parallel_binary_name" = "${parallel}/bin/parallel";
        "$pre_command" = true;
        "${placeholder "out"}/libexec/bats-core/bats" = true;
        "${placeholder "out"}/libexec/bats-core/bats-exec-test" = true;
        "${placeholder "out"}/libexec/bats-core/bats-preprocess" = true;

        source = [
          "${placeholder "out"}/lib/bats-core/validator.bash"
          "${placeholder "out"}/lib/bats-core/preprocessing.bash"
          "$BATS_TEST_SOURCE"
          "${placeholder "out"}/lib/bats-core/tracing.bash"
          "${placeholder "out"}/lib/bats-core/test_functions.bash"
          "$library_load_path"
          "${placeholder "out"}/lib/bats-core/common.bash"
          "${placeholder "out"}/lib/bats-core/semaphore.bash"
          "${placeholder "out"}/lib/bats-core/formatter.bash"
          "${placeholder "out"}/lib/bats-core/warnings.bash"
          "$setup_suite_file" # via cli arg
        ];
      };

      scripts = [
        "bin/bats"
        "libexec/bats-core/*"
        "lib/bats-core/*"
      ];
    };
  };

  passthru.libraries = callPackages ./libraries.nix { };

  passthru.tests = {
    # to see when updates would break things, include packages
    # that use nixpkgs' bats for testing (as long as they
    # aren't massive builds)
    inherit bash-preexec locate-dominating-file;

    libraries =
      let
        testScript = writeText "bats-libraries-test-script" ''
          setup() {
            bats_load_library bats-support
            bats_load_library bats-assert
            bats_load_library bats-file
            bats_load_library bats-detik/detik.bash

            bats_require_minimum_version 1.5.0

            TEST_TEMP_DIR="$(temp_make --prefix 'nixpkgs-bats-test')"
          }

          teardown() {
            temp_del "$TEST_TEMP_DIR"
          }

          @test echo_hi {
            run -0 echo hi
            assert_output "hi"
          }

          @test cp_failure {
            run ! cp
            assert_line --index 0 "cp: missing file operand"
            assert_line --index 1 "Try 'cp --help' for more information."
          }

          @test file_exists {
            echo "hi" > "$TEST_TEMP_DIR/hello.txt"
            assert_file_exist "$TEST_TEMP_DIR/hello.txt"
            run cat "$TEST_TEMP_DIR/hello.txt"
            assert_output "hi"
          }
        '';
        batsWithLibraries = bats.withLibraries (p: [
          p.bats-support
          p.bats-assert
          p.bats-file
          p.bats-detik
        ]);
      in
      runCommand "${bats.name}-with-libraries-test" { } ''
        ${lib.getExe batsWithLibraries} "${testScript}"
        touch "$out"
      '';

    resholve = resholve.tests.cli;

    upstream = bats.unresholved.overrideAttrs (old: {
      inherit doInstallCheck;

      nativeInstallCheckInputs = [
        ncurses
        parallel # skips some tests if it can't detect
        flock # skips some tests if it can't detect
        procps
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ lsof ];

      installCheckPhase = ''
        # TODO: cut if https://github.com/bats-core/bats-core/issues/418 allows
        sed -i '/test works even if PATH is reset/a skip "disabled for nix build"' test/bats.bats

        # skip tests that assume bats `install.sh` will be in BATS_ROOT
        rm test/root.bats

      ''
      + (lib.optionalString stdenv.hostPlatform.isDarwin ''
        # skip new timeout tests which are failing on macOS for unclear reasons
        # This might relate to procps not having a pkill?
        rm test/timeout.bats
      '')
      + ''

        # test generates file with absolute shebang dynamically
        substituteInPlace test/install.bats --replace \
          "/usr/bin/env bash" "${bash}/bin/bash"

        ${bats}/bin/bats test
        touch $out
      '';

      dontInstall = true; # just need the build directory
      # after 411981, make-symlinks-relative breaks a parallelization test:
      # "setup_file is not over parallelized"
      dontRewriteSymlinks = true;
      name = "${bats.name}-tests";
    });
  }
  // lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) {
    # TODO:
    # - kikit's kicad dependency is marked broken on darwin atm
    #   may be able to fold this up if that resolves.
    # - packcc's tests currently broken on darwin (apr 2026)
    inherit kikit packcc;
  };

  passthru.withLibraries =
    selector:
    symlinkJoin {
      nativeBuildInputs = [
        makeWrapper
      ];

      postBuild = ''
        wrapProgram "$out/bin/bats" \
          --suffix BATS_LIB_PATH : "$out/share/bats"
      '';

      name = "bats-with-libraries-${bats.version}";

      paths = [
        bats
      ]
      ++ selector bats.libraries;

      meta = removeAttrs finalAttrs.meta [ "position" ];
    };

  meta = {
    description = "Bash Automated Testing System";

    longDescription = ''
      Bats can be extended with libraries. The available libraries are:

      - `bats-assert`
      - `bats-file`
      - `bats-detik`
      - `bats-support`

      An example of building this package with a few libraries:
      ```nix
      bats.withLibraries (p: [
        p.bats-assert
        p.bats-support
      ])
      ```
    '';

    homepage = "https://github.com/bats-core/bats-core";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ abathur ];
    platforms = lib.platforms.unix;
    mainProgram = "bats";
  };
})
