{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  cctools,
  copyDesktopItems,
  electron_41,
  fetchPnpmDeps,
  installShellFiles,
  libicns,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  node-gyp,
  nodejs,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_10,
  python3,
  writeDarwinBundle,
  xcbuild,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    appName = "T3 Code (Alpha)";
    electron = electron_41;
    pnpm = pnpm_10;
    desktopIcon =
      if stdenv.hostPlatform.isDarwin then
        "assets/prod/black-macos-1024.png"
      else
        "assets/prod/black-universal-1024.png";

  in
  {
    pname = "t3code-unwrapped";
    version = "0.0.28";

    src = fetchFromGitHub {
      owner = "pingdotgg";
      repo = "t3code";
      tag = "v${finalAttrs.version}";
      hash = "sha256-InVrw9L281QSSPrHSiZuivmb+FkYEd6FkHwHIAAxmGk=";
    };

    postPatch = ''
      substituteInPlace apps/web/vite.config.ts \
        --replace-fail 'const host = process.env.HOST?.trim() || "localhost";' \
                       'const host = process.env.HOST?.trim() || "127.0.0.1";'
    '';

    strictDeps = true;

    nativeBuildInputs = [
      installShellFiles
      makeBinaryWrapper
      node-gyp
      nodejs
      python3
      pnpmConfigHook
      pnpmBuildHook
      pnpm
      cacert
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cctools.libtool
      libicns
      writeDarwinBundle
      xcbuild
    ];

    preBuild = ''
      node scripts/update-release-package-versions.ts ${finalAttrs.version}

      export npm_config_nodedir=${nodejs}
      export ELECTRON_SKIP_BINARY_DOWNLOAD=1
      # Exclude the `@t3tools/monorepo` workspace from the pending rebuild since
      # `vp config` needs git
      pnpm rebuild --pending "''${pnpmInstallFlags[@]}" --filter '!@t3tools/monorepo'
    '';

    postBuild = ''
      pnpm vp cache clean
    '';

    installPhase = ''
      runHook preInstall

      mkdir --parents "$out"/libexec/t3code/apps/desktop "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode node_modules "$out"/libexec/t3code
      cp --recursive --no-preserve=mode apps/server/{node_modules,dist} "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode \
        apps/desktop/{package.json,node_modules,dist-electron} \
        "$out"/libexec/t3code/apps/desktop

      mkdir --parents "$out"/libexec/t3code/apps/desktop/prod-resources
      install --mode=444 ${desktopIcon} \
        "$out"/libexec/t3code/apps/desktop/prod-resources/icon.png

      find "$out"/libexec/t3code -xtype l -delete

      makeWrapper ${lib.getExe nodejs} "$out"/bin/t3 \
        --add-flags "$out"/libexec/t3code/apps/server/dist/bin.mjs

      makeWrapper ${lib.getExe electron} "$out"/bin/t3code-desktop \
        --add-flags "$out"/libexec/t3code/apps/desktop \
        --inherit-argv0
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # node-pty tries to chmod this helper at runtime, but the Nix store is
      # immutable by then.
      find "$out"/libexec/t3code \
        -path '*/node-pty/prebuilds/darwin-*/spawn-helper' \
        -exec chmod 755 {} +

      mkdir --parents "$out/Applications/${appName}.app/Contents/"{MacOS,Resources}
      png2icns \
        "$out/Applications/${appName}.app/Contents/Resources/t3code.icns" \
        ${desktopIcon}

      # writeDarwinBundle is a shebangless bash script; run it explicitly via
      # stdenv.shell to avoid Darwin's intermittent ENOEXEC fallback issues.
      ${stdenv.shell} ${lib.getExe writeDarwinBundle} \
        "$out" "${appName}" t3code-desktop t3code
    ''
    + ''
      mkdir --parents \
        "$out"/share/icons/hicolor/scalable/apps
      install --mode=444 ${desktopIcon} \
        "$out"/share/icons/t3code.png
      install --mode=444 assets/prod/logo.svg \
        "$out"/share/icons/hicolor/scalable/apps/t3code.svg

      runHook postInstall
    '';

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      for shell in bash fish zsh; do
        installShellCompletion --cmd t3 --"$shell" <("$out/bin/t3" --completions "$shell")
      done
    '';

    __structuredAttrs = true;

    desktopItems = [
      (makeDesktopItem {
        categories = [ "Development" ];
        comment = "Minimal web GUI for coding agents";
        desktopName = appName;
        exec = "t3code-desktop %U";
        icon = "t3code";
        name = "t3code";
        startupWMClass = "t3code";
        terminal = false;
      })
    ];

    # Many dependencies vendors many prebuilt native artifacts for non-host
    # platforms, and some of those binaries are statically linked. Let fixup
    # handle wrappers, shebangs, and stripping, but skip patchelf on the
    # vendored tree.
    dontPatchELF = true;
    # The tmpdir audit hook also shells out to patchelf while scanning every
    # vendored ELF for leaked build paths. That produces spurious warnings on
    # some dependencies' static foreign-platform binaries.
    noAuditTmpdir = true;
    pnpmBuildScript = "build:desktop";

    pnpmDeps = fetchPnpmDeps {
      inherit pnpm;

      inherit (finalAttrs)
        pname
        version
        src
        pnpmWorkspaces
        ;

      fetcherVersion = 4;
      hash = "sha256-+JqW/iI0wdRPxyL7y6ggD/+AvwwZXs9+fSUtG/SgW9s=";
    };

    pnpmWorkspaces = [
      # `...` suffix is used to also include other workspace packages that are
      # directly or indirectly depended on by the listed packages, such as
      # `@t3tools/contracts` and `@t3tools/shared`.
      "@t3tools/monorepo"
      "t3..."
      "@t3tools/desktop..."
      "@t3tools/scripts..."
    ];

    passthru = {
      updateScript = nix-update-script {
        attrPath = "t3code.unwrapped";
        extraArgs = [ "--use-github-releases" ];
      };
    };

    meta = {
      inherit (nodejs.meta) platforms;
      description = "Minimal web GUI for coding agents";
      homepage = "https://t3.codes";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/${finalAttrs.src.tag}";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        iamanaws
        qweered
      ];

      mainProgram = "t3code-desktop";
      downloadPage = "https://t3.codes/download";
    };
  }
)
