{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  dash,
  libedit,
  patchRcPathPosix,
  pkg-config,
  runCommand,
  # Reverse dependency smoke tests
  tests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dash";
  version = "0.5.13.4";

  src = fetchurl {
    url = "http://gondor.apana.org.au/~herbert/dash/files/dash-${finalAttrs.version}.tar.gz";
    hash = "sha256-0Q39Qc2lkWVWDbOcqRXCxKdjb/8EKB2NLfd62Sx1Pis=";
  };

  strictDeps = true;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isStatic [ pkg-config ];
  buildInputs = [ libedit ];
  configureFlags = [ "--with-libedit" ];

  preConfigure = lib.optional stdenv.hostPlatform.isStatic ''
    export LIBS="$(''${PKG_CONFIG:-pkg-config} --libs --static libedit)"
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  hardeningDisable = [ "strictflexarrays3" ];

  passthru = {
    shellPath = "/bin/dash";

    tests = {
      "execute-simple-command" = runCommand "dash-execute-simple-command" { } ''
        mkdir $out
        ${lib.getExe dash} -c 'echo "Hello World!" > $out/success'
        [ -s $out/success ]
        grep -q "Hello World" $out/success
      '';

      /**
        Reverse dependency smoke tests. Build success of `dash.tests` informs
        whether an update makes it into staging.
      */
      reverseDependencies = lib.recurseIntoAttrs {
        # Not sure if effective smoke test, but cheap
        patch-rc-path-posix = patchRcPathPosix.tests.test-posix;

        writers = lib.recurseIntoAttrs {
          bin = tests.writers.bin.dash;
          simple = tests.writers.simple.dash;
        };
      };
    };
  };

  meta = {
    description = "POSIX-compliant implementation of /bin/sh that aims to be as small as possible";
    homepage = "http://gondor.apana.org.au/~herbert/dash/";

    license = with lib.licenses; [
      bsd3
      gpl2Plus
    ];

    platforms = lib.platforms.unix;
    mainProgram = "dash";
  };
})
