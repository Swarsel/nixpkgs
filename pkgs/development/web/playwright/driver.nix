{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  cacert,
  callPackage,
  chromium,
  ffmpeg,
  jq,
  linkFarm,
  makeFontsConf,
  makeWrapper,
  nodejs,
}:
let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";
  browsersJSON = (lib.importJSON ./browsers.json).browsers;

  version = "1.61.1";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "playwright";
    rev = "v${version}";
    hash = "sha256-FC3Sjh4LCTqftudcwt7KO3g3c2uyWv7PixhWqSZZR4Y=";
  };

  playwright = buildNpmPackage {
    inherit version src;
    pname = "playwright";

    postPatch = ''
      sed -i '/\/\/ Update test runner./,/^\s*$/{d}' utils/build/build.js
      # The dlopen library check uses ldconfig which doesn't work under Nix.
      # These libraries are already provided via rpath by autoPatchelfHook and wrapProgram.
      substituteInPlace packages/playwright-core/src/server/registry/index.ts \
        --replace-fail "['libGLESv2.so.2', 'libx264.so']" "[]"
    '';

    nativeBuildInputs = [
      cacert
      jq
    ];

    npmDepsHash = "sha256-DTRhYHRaPlthyRcD2azEIKMPaRwROLuLOdUC27Rk5zM=";
    env.ELECTRON_SKIP_BINARY_DOWNLOAD = true;

    installPhase = ''
      runHook preInstall

      shopt -s extglob

      mkdir -p "$out/lib/node_modules/playwright"
      cp -r packages/playwright/!(bundles|src|node_modules|.*) "$out/lib/node_modules/playwright"

      # for not supported platforms (such as NixOS) playwright assumes that it runs on ubuntu-20.04
      # that forces it to use overridden webkit revision
      # let's remove that override to make it use latest revision provided in Nixpkgs
      # https://github.com/microsoft/playwright/blob/baeb065e9ea84502f347129a0b896a85d2a8dada/packages/playwright-core/src/server/utils/hostPlatform.ts#L111
      jq '(.browsers[] | select(.name == "webkit") | .revisionOverrides) |= del(."ubuntu20.04-x64", ."ubuntu20.04-arm64")' \
        packages/playwright-core/browsers.json > browser.json.tmp && mv browser.json.tmp packages/playwright-core/browsers.json
      mkdir -p "$out/lib/node_modules/playwright-core"
      cp -r packages/playwright-core/!(bundles|src|bin|.*) "$out/lib/node_modules/playwright-core"

      mkdir -p "$out/lib/node_modules/@playwright/test"
      cp -r packages/playwright-test/* "$out/lib/node_modules/@playwright/test"

      runHook postInstall
    '';

    sourceRoot = "${src.name}"; # update.sh depends on sourceRoot presence

    meta = {
      inherit (nodejs.meta) platforms;
      description = "Framework for Web Testing and Automation";
      homepage = "https://playwright.dev";
      license = lib.licenses.asl20;

      maintainers = with lib.maintainers; [
        kalekseev
      ];
    };
  };

  playwright-core = stdenv.mkDerivation (finalAttrs: {
    inherit (playwright) version src meta;
    pname = "playwright-core";

    installPhase = ''
      runHook preInstall

      cp -r ${playwright}/lib/node_modules/playwright-core "$out"

      runHook postInstall
    '';

    passthru = {
      inherit browsersJSON;
      inherit components;
      browsers = browsers { };

      browsers-chromium = browsers {
        withChromiumHeadlessShell = false;
        withFirefox = false;
        withWebkit = false;
      };

      selectBrowsers = browsers;

      tests.browser-downloads = callPackage ./browser-downloads-test.nix {
        playwright-core = finalAttrs.finalPackage;
      };

      updateScript = ./update.sh;
    };
  });

  playwright-test = stdenv.mkDerivation (finalAttrs: {
    inherit (playwright) version src;
    pname = "playwright-test";
    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall

      shopt -s extglob
      mkdir -p $out/bin
      cp -r ${playwright}/* $out

      makeWrapper "${nodejs}/bin/node" "$out/bin/playwright" \
        --add-flags "$out/lib/node_modules/@playwright/test/cli.js" \
        --prefix NODE_PATH : ${placeholder "out"}/lib/node_modules \
        --set-default PLAYWRIGHT_BROWSERS_PATH "${playwright-core.passthru.browsers}"

      runHook postInstall
    '';

    meta = playwright.meta // {
      mainProgram = "playwright";
    };
  });

  components = {
    chromium = callPackage ./chromium.nix {
      inherit system throwSystem;
      inherit (browsersJSON.chromium) revision browserVersion;

      fontconfig_file = makeFontsConf {
        fontDirectories = [ ];
      };
    };

    chromium-headless-shell = callPackage ./chromium-headless-shell.nix {
      inherit system throwSystem;
      inherit (browsersJSON."chromium-headless-shell") revision browserVersion;
    };

    ffmpeg = callPackage ./ffmpeg.nix {
      inherit system throwSystem;
      inherit (browsersJSON.ffmpeg) revision;
    };

    firefox = callPackage ./firefox.nix {
      inherit system throwSystem;
      inherit (browsersJSON.firefox) revision;
    };

    webkit = callPackage ./webkit.nix {
      inherit system throwSystem;
      inherit (browsersJSON.webkit) revision;
    };
  };

  browsers = lib.makeOverridable (
    {
      fontconfig_file ? makeFontsConf {
        fontDirectories = [ ];
      },
      withChromium ? true,
      withChromiumHeadlessShell ? true,
      withFfmpeg ? true,
      withFirefox ? true,
      withWebkit ? true, # may require `export PLAYWRIGHT_HOST_PLATFORM_OVERRIDE="ubuntu-24.04"`
    }:
    let
      browsers =
        lib.optionals withChromium [ "chromium" ]
        ++ lib.optionals withChromiumHeadlessShell [ "chromium-headless-shell" ]
        ++ lib.optionals withFirefox [ "firefox" ]
        ++ lib.optionals withWebkit [ "webkit" ]
        ++ lib.optionals withFfmpeg [ "ffmpeg" ];
    in
    linkFarm "playwright-browsers" (
      lib.listToAttrs (
        map (
          name:
          let
            value = browsersJSON.${name};
          in
          lib.nameValuePair
            # TODO check platform for revisionOverrides
            "${lib.replaceStrings [ "-" ] [ "_" ] name}-${value.revision}"
            components.${name}
        ) browsers
      )
    )
  );
in
{
  playwright-core = playwright-core;
  playwright-test = playwright-test;
}
