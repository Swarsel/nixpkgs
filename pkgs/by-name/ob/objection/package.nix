{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  aapt,
  android-tools,
  androidenv,
  apksigner,
  apktool,
  buildNpmPackage,
  frida-tools,
  makeWrapper,
  python3Packages,
}:
let
  androidComposition = androidenv.composeAndroidPackages { };
  version = "1.12.4";
  src = fetchFromGitHub {
    owner = "sensepost";
    repo = "objection";
    tag = version;
    hash = "sha256-sXMhLwTsksLRFBGEsKSmDaD0+uDugz2U3yn50rHFbnQ=";
  };

  fridaVersion = "17.5.1";

  supportedPlatforms = {
    aarch64-darwin = {
      fridaArch = "darwin-arm64";
      fridaHash = "sha256-mR6HM9rmRmXhWqXA0GC4Xkdj9KVSthhtvMAzijE+j5c=";
    };

    aarch64-linux = {
      fridaArch = "linux-arm64";
      fridaHash = "sha256-BsCgpHS3IFMPciu9hsdu9vWwKu+pon+EtqF10NO1EAc=";
    };

    armv7l-linux = {
      fridaArch = "linux-armv7l";
      fridaHash = "sha256-mNl+kP+9a4AC2Tf1SM7mYL5b+j4pPz+E9R88JjLgifE=";
    };

    i686-linux = {
      fridaArch = "linux-ia32";
      fridaHash = "sha256-vLwf+EwWNDLznda8J+xVqp8XmuivdZ0VKgISR9YoQR0=";
    };

    x86_64-freebsd = {
      fridaArch = "freebsd-x64";
      fridaHash = "sha256-ddvUtdZJdVH9O7np04ayB/Nebxq4Raw0eAQJpFAFl6Q=";
    };

    x86_64-linux = {
      fridaArch = "linux-x64";
      fridaHash = "sha256-g7uZs/fUwraIu6SZaU9kGGVuzD/nyqmXHVp0zL3jhdY=";
    };
  };

  currentPlatform =
    supportedPlatforms.${stdenv.hostPlatform.system}
      or (throw "frida Node.js binding: unsupported system ${stdenv.hostPlatform.system}");

  fridaNodeBinding = fetchurl {
    hash = currentPlatform.fridaHash;
    url = "https://github.com/frida/frida/releases/download/${fridaVersion}/frida-v${fridaVersion}-napi-v8-${currentPlatform.fridaArch}.tar.gz";
  };

  runtimeTools = [
    apktool
    aapt
    apksigner
    android-tools
  ];

  agent = buildNpmPackage {
    inherit version src;
    pname = "objection-agent";

    postPatch = ''
      substituteInPlace package.json \
        --replace-fail '"frida-compile src/index.ts -o ../objection/agent.js -T none"' \
                       '"frida-compile src/index.ts -o ./agent.js -T none"'
    '';

    npmDepsHash = "sha256-oG0uMhy6Gv2lc1SNJwqnvYRdhhqWwPMY0MCDMt2hPf0=";

    preBuild = ''
      mkdir -p node_modules/frida
      tar -xzf ${fridaNodeBinding} -C node_modules/frida
    '';

    installPhase = ''
      runHook preInstall
      install -Dm644 agent.js $out/agent.js
      runHook postInstall
    '';

    npmRebuildFlags = [ "--ignore-scripts" ];
    sourceRoot = "source/agent";
  };
in
python3Packages.buildPythonApplication {
  inherit version src;
  pname = "objection";

  nativeBuildInputs = [
    makeWrapper
  ];

  doCheck = true;

  postFixup = ''
    mkdir -p "$out/bin-wrapped"
    ln -s "${aapt}/bin/aapt2" "$out/bin-wrapped/aapt"
    BUILD_TOOLS_PATH="${androidComposition.androidsdk}/libexec/android-sdk/build-tools"
    if [ -d "$BUILD_TOOLS_PATH" ]; then
      LATEST_BUILD_TOOLS=$(ls -d "$BUILD_TOOLS_PATH"/* 2>/dev/null | sort -V | tail -1)
      [ -n "$LATEST_BUILD_TOOLS" ] && ln -s "$LATEST_BUILD_TOOLS/zipalign" "$out/bin-wrapped/zipalign" 2>/dev/null || true
    fi

    wrapProgram $out/bin/objection \
      --prefix PATH : "$out/bin-wrapped:${lib.makeBinPath runtimeTools}"
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    frida-python
    frida-tools
    prompt-toolkit
    click
    tabulate
    semver
    delegator-py
    requests
    flask
    pygments
    setuptools
    packaging
    litecli
  ];

  postUnpack = ''
    cp ${agent}/agent.js $sourceRoot/objection/
  '';

  pyproject = true;

  pythonImportsCheck = [
    "objection"
  ];

  pythonRuntimeDepsCheck = true;

  meta = {
    description = "Runtime mobile exploration toolkit, powered by Frida";

    longDescription = ''
      objection is a runtime mobile exploration toolkit, powered by Frida,
      built to help you assess the security posture of your mobile applications,
      without needing a jailbreak.
    '';

    homepage = "https://github.com/sensepost/objection";
    changelog = "https://github.com/sensepost/objection/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nullstring1 ];
    platforms = builtins.attrNames supportedPlatforms;
    mainProgram = "objection";
  };
}
