{
  lib,
  fetchFromGitHub,
  beam27Packages,
  brotli,
  buildNpmPackage,
  buildPackages,
  cmake,
  esbuild,
  nix-update-script,
  nixosTests,
  nodejs,
  npm-lockfile-fix,
  runCommand,
  rustPlatform,
}:

let
  pname = "plausible";
  version = "3.2.1";
  mixEnv = "ce";

  src = fetchFromGitHub {
    owner = "plausible";
    repo = "analytics";
    rev = "v${version}";
    hash = "sha256-2roIj0s2cybYdGmmJSPJ5Rc1gNunxlYew9JR5xxMv+k=";

    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/assets/package-lock.json
      sed -ie '
        /defp deps do/ {
          n
          /\[/ a\
            \{:rustler, ">= 0.0.0", optional: true \},
          }
      ' $out/mix.exs
      cat >> $out/config/config.exs <<EOF
      config :mjml, Mjml.Native,
        crate: :mjml_nif,
        skip_compilation?: true
      EOF
    '';
  };

  assets = buildNpmPackage {
    inherit version;
    pname = "${pname}-assets";
    src = "${src}/assets";
    npmDepsHash = "sha256-grYxPRzpu3pcv3lyTQxx0RDhmgFhsOKZoYbzd701xjA=";

    installPhase = ''
      runHook preInstall
      cp -r . "$out"
      runHook postInstall
    '';

    dontNpmBuild = true;
  };

  tracker = buildNpmPackage {
    inherit version;
    pname = "${pname}-tracker";
    src = "${src}/tracker";
    npmDepsHash = "sha256-hrsvQXvbcfRDUc1qinyUJ7Oh4yMM1e+UEdYudjYyJxk=";

    installPhase = ''
      runHook preInstall
      cp -r . "$out"
      runHook postInstall
    '';

    dontNpmBuild = true;
  };

  # lazy_html (new dep since 3.1.0) builds a NIF against lexbor
  # its Makefile clones lexbor at build time (which sandbox forbids)
  # pre-seed commit in lazy_html's mix.exs so the clone target is skipped
  # and force a build in preBuild below
  lexborCommit = "244b84956a6dc7eec293781d051354f351274c46";
  lexborSrc = fetchFromGitHub {
    hash = "sha256-Oup/lGU8a9Dqfho4Llg39t9Y9n4xfUmGk0772OkpnLQ=";
    owner = "lexbor";
    repo = "lexbor";
    rev = lexborCommit;
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit
      pname
      version
      src
      mixEnv
      ;

    hash = "sha256-fm/elkCNpu5sduBxly06i/z30Y9BMtt+qthXmLuvlUc=";
  };

  mjmlNif = rustPlatform.buildRustPackage {
    pname = "mjml-native";
    version = "";
    src = "${mixFodDeps}/mjml/native/mjml_nif";
    cargoHash = "sha256-a8xSRdFtMYF0n2rl7A5ZgHoaunUJLVJwHvrkc9uyZKo=";

    env = {
      RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "true";
      RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";
    };

    doCheck = false;
  };

  patchedMixFodDeps =
    runCommand mixFodDeps.name
      {
        inherit (mixFodDeps) hash;
      }
      ''
        mkdir $out
        cp -r --no-preserve=mode ${mixFodDeps}/. $out

        mkdir -p $out/mjml/priv/native
        for lib in ${mjmlNif}/lib/*
        do
          # normalies suffix to .so, otherswise build would fail on darwin
          file=''${lib##*/}
          base=''${file%.*}
          ln -s "$lib" $out/mjml/priv/native/$base.so
          # mjml >= 4.0 loads through RustlerPrecompiled (expects NIF name w/o lib prefix)
          ln -s "$lib" $out/mjml/priv/native/''${base#lib}.so
        done

        mkdir -p $out/lazy_html/_build/c/third_party/lexbor
        cp -r --no-preserve=mode ${lexborSrc} \
          $out/lazy_html/_build/c/third_party/lexbor/${lexborCommit}
      '';

  beamPackages = beam27Packages.extend (self: super: { elixir = self.elixir_1_18; });

in
beamPackages.mixRelease rec {
  inherit
    pname
    version
    src
    mixEnv
    ;

  nativeBuildInputs = [
    nodejs
    brotli
    cmake
  ];

  env = {
    APP_VERSION = version;
    RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "true";
    RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";
  };

  # deps are compiled in mixRelease configurePhase
  # so the force_build switch must be in place before then
  # preBuild would be too late
  preConfigure = ''
    cat >> config/config.exs <<EOF
    config :elixir_make, :force_build, lazy_html: true
    EOF
  '';

  preBuild = ''
    rm -r assets tracker
    cp --no-preserve=mode -r ${assets} assets
    # tracker must be writable since 3.1.0
    # compile.js emits npm_package/plausible.js
    cp --no-preserve=mode -r ${tracker} tracker

    # Fix cross-compilation with buildPackages
    # since tailwindcss is not available for RiscV
    # plausible >= 3.1.0 needs tailwind v4
    cat >> config/config.exs <<EOF
    config :tailwind, path: "${lib.getExe buildPackages.tailwindcss_4}"
    config :esbuild, path: "${lib.getExe esbuild}"
    EOF
  '';

  postBuild = ''
    npm run deploy --prefix ./tracker

    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
    mix do deps.loadpaths --no-deps-check, phx.digest priv/static
  '';

  dontUseCmakeConfigure = true;
  mixFodDeps = patchedMixFodDeps;

  passthru = {
    inherit
      assets
      tracker
      mjmlNif
      ;

    tests = nixosTests.plausible;

    updateScript = nix-update-script {
      extraArgs = [
        "-s"
        "tracker"
        "-s"
        "assets"
        "-s"
        "mjmlNif"
      ];
    };
  };

  meta = {
    description = "Simple, open-source, lightweight (< 1 KB) and privacy-friendly web analytics alternative to Google Analytics";
    homepage = "https://plausible.io/";
    changelog = "https://github.com/plausible/analytics/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      stepbrobd
      nh2
    ];

    platforms = lib.platforms.unix;
    mainProgram = "plausible";
  };
}
