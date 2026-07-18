{
  lib,
  stdenv,
  callPackage,
  chez,
  chez-racket,
  clang,
  gambit,
  gmp,
  idris2-src,
  idris2-version,
  idris2Packages,
  installShellFiles,
  libidris2_support,
  nodejs,
  testers,
  zsh,
}:
let
  inherit (stdenv.hostPlatform) extensions;

  # Runtime library
  libsupportLib = lib.makeLibraryPath [ libidris2_support ];
  libsupportShare = lib.makeSearchPath "share" [ libidris2_support ];

  platformChez =
    if (stdenv.system == "x86_64-linux") || (lib.versionAtLeast chez.version "10.0.0") then
      chez
    else
      chez-racket;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "idris2";
  version = idris2-version;
  src = idris2-src;

  postPatch = ''
    shopt -s globstar

    # Patch all occurences of the support lib with an absolute path so it
    # works without wrapping.
    substituteInPlace **/*.idr \
      --replace-quiet "libidris2_support" "${libidris2_support}/lib/libidris2_support${extensions.sharedLibrary}"

    # The remove changes libidris2_support.a to /nix/store/..../libidris2_support.so.a
    # Fix that up so the reference-counted C backend works
    substituteInPlace src/Compiler/RefC/CC.idr \
      --replace-fail "libidris2_support${extensions.sharedLibrary}.a" "libidris2_support.a"

    substituteInPlace bootstrap-stage2.sh \
      --replace-fail "MAKE all" "MAKE idris2-exec"

    patchShebangs --build tests
  '';

  strictDeps = true;

  nativeBuildInputs = [
    clang
    platformChez
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ zsh ];

  buildInputs = [
    platformChez
    gmp
    libidris2_support
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "IDRIS2_SUPPORT_DIR=${libsupportLib}"
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin "OS=";

  # The name of the main executable of pkgs.chez is `scheme`
  buildFlags = [
    "bootstrap"
    "SCHEME=scheme"
    "IDRIS2_LIBS=${libsupportLib}"
    "IDRIS2_DATA=${libsupportShare}"
  ];

  doCheck = false;

  nativeCheckInputs = [
    gambit
    nodejs
  ];

  checkFlags = [
    "INTERACTIVE="
    "IDRIS2_DATA=${libsupportShare}"
    "IDRIS2_LIBS=${libsupportLib}"
    "TEST_IDRIS2_DATA=${libsupportShare}"
    "TEST_IDRIS2_LIBS=${libsupportLib}"
    "TEST_IDRIS2_SUPPORT_DIR=${libsupportLib}"
  ];

  postInstall = ''
    # Remove existing idris2 wrapper that sets incorrect LD_LIBRARY_PATH
    rm $out/bin/idris2

    # The only thing we need from idris2_app is the actual binary, which is a Chez
    # scheme object and for some reason *.so on darwin too
    mv $out/bin/idris2_app/idris2.so $out/bin/idris2

    rm -rf $out/bin/idris2_app
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd idris2 \
      --bash <($out/bin/idris2 --bash-completion-script idris2)
  '';

  checkTarget = "test";
  enableParallelBuilding = true;
  installTargets = "install-idris2";

  # Run package tests
  passthru = {
    inherit libidris2_support;
    chez = platformChez;

    tests = {
      prelude = testers.runCommand {
        nativeBuildInputs = [
          (finalAttrs.finalPackage.withPackages (_: [ ]))
        ];

        name = "idris2-prelude-wrapped";

        script = ''
          local packages=$(idris2 --list-packages)

          if ! [[ $packages =~ "contrib" ]]; then
            exit 1
          fi

          touch "$out"
        '';
      };

      wrapped = testers.testVersion {
        package = finalAttrs.finalPackage.withPackages (p: [ p.idris2Api ]);
      };
    }
    // (callPackage ./tests.nix {
      idris2 = finalAttrs.finalPackage.withPackages (_: [ ]);
      idris2Packages = idris2Packages.override { idris2 = finalAttrs.finalPackage; };
    });

    updateScript = ./update.nu;

    withPackages =
      f:
      callPackage ./wrapped.nix {
        extraPackages = f idris2Packages;
        idris2-unwrapped = finalAttrs.finalPackage;
      };
  };

  meta = {
    description = "Purely functional programming language with first class types";
    homepage = "https://github.com/idris-lang/Idris2";
    changelog = "https://github.com/idris-lang/Idris2/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      fabianhjr
      wchresta
      mattpolzin
    ];

    platforms = lib.platforms.all;
    mainProgram = "idris2";
  };
})
