{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  git,
  graphite-cli,
  installShellFiles,
  testers,
}:

let
  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  suffix = selectSystem {
    aarch64-darwin = "darwin-arm64";
    aarch64-linux = "linux-arm64";
    x86_64-linux = "linux-x64";
  };

  version = "1.8.6";

  meta = {
    description = "CLI that makes creating stacked git changes fast & intuitive";
    homepage = "https://graphite.dev/docs/graphite-cli";
    changelog = "https://graphite.dev/docs/cli-changelog";
    license = lib.licenses.unfree; # no license specified
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ joshheinrichs-shopify ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "gt";
    downloadPage = "https://www.npmjs.com/package/@withgraphite/graphite-cli";
  };

  passthru = {
    tests.version = testers.testVersion {
      command = "gt --version";
      package = graphite-cli;
    };

    updateScript = ./update.sh;
  };

  shellCompletions = ''
    installShellCompletion --cmd gt \
      --bash <($out/bin/gt completion) \
      --zsh <(ZSH_NAME=zsh $out/bin/gt completion) \
      --fish <($out/bin/gt fish)
  '';

  unwrapped = stdenv.mkDerivation {
    inherit version meta passthru;
    pname = "graphite-cli-unwrapped";

    src = fetchurl {
      url = "https://registry.npmjs.org/@withgraphite/graphite-cli-${suffix}/-/graphite-cli-${suffix}-${version}.tgz";

      hash = selectSystem {
        aarch64-darwin = "sha256-6eogi8fMOD5IgRyEdPRxdDa17WytB1JwTpKRzyyhQ2Q=";
        aarch64-linux = "sha256-Z4yY26hXf8++TX5tJcqufsAULTn9oUL90d9tDZj5d/k=";
        x86_64-linux = "sha256-YnG3iw35ZEyGbB9vGdcnj0qkvUfyLuaIEB5l09hkRck=";
      };
    };

    strictDeps = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
      git
      installShellFiles
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 bin/gt $out/bin/gt
      runHook postInstall
    '';

    # gt tries to create ~/.config/graphite/aliases on startup and exits 1
    # with no output when HOME is not writable, which would leave the
    # completion files empty.
    postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
      export HOME=$(mktemp -d)
      ${shellCompletions}
    '';

    dontBuild = true;
    dontConfigure = true;
    # Skip fixup on all platforms: strip discards the vercel/pkg virtual
    # filesystem appended to the binary (see the comment below), leaving a
    # binary that fails at runtime with "Pkg: Error reading from file."
    dontFixup = true;
  };
in
# The binary is built with vercel/pkg, which appends a virtual filesystem to
# the executable at fixed byte offsets. patchelf and strip shift those offsets,
# corrupting the embedded data, so the binary must remain completely unmodified.
# On Linux we use buildFHSEnv to provide /lib64/ld-linux-*.so.* and shared
# libraries without touching the binary. On Darwin this isn't needed.
if stdenv.hostPlatform.isLinux then
  (buildFHSEnv {
    inherit version passthru;
    pname = "graphite-cli";

    extraInstallCommands = ''
      ln -s $out/bin/graphite-cli $out/bin/gt
      source ${installShellFiles}/nix-support/setup-hook
      ${shellCompletions}
    '';

    runScript = "gt";

    targetPkgs = pkgs: [
      unwrapped
      pkgs.stdenv.cc.cc.lib
      git
    ];

    meta = meta // {
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }).overrideAttrs
    { strictDeps = true; }
else
  unwrapped
