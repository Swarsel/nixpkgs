{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  copyDesktopItems,
  darwin,
  electron,
  fetchPnpmDeps,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs,
  pandoc,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_11,
  replaceVars,
  xdg-utils,
}:

let
  inherit (stdenv.hostPlatform) isLinux isDarwin system;

  pnpm = pnpm_11;

  platformIds = {
    "aarch64-darwin" = "darwin-arm64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-linux" = "linux";
  };

  platformId = platformIds.${system} or (throw "Unsupported platform: ${system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "siyuan";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "siyuan-note";
    repo = "siyuan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K31h2noDpTn7vCXj16K2dxRPww5z+HC/nA4Gn5MAVms=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ]
  ++ lib.optionals isLinux [
    pnpmBuildHook
    makeWrapper
    copyDesktopItems
  ]
  ++ lib.optionals isDarwin [
    darwin.autoSignDarwinBinariesHook
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postConfigure = ''
    # remove prebuilt pandoc archives
    rm -r pandoc

    # link kernel into the correct starting place so that electron-builder can copy it to it's final location
    mkdir kernel-${platformId}
    ln -s ${finalAttrs.kernel}/bin/kernel kernel-${platformId}/SiYuan-Kernel

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
  '';

  postBuild = ''
    electronBuilderArgs=(
      --dir
      --config electron-builder-${platformId}.yml
      -c.electronDist=electron-dist
      -c.electronVersion=${electron.version}
      -c.mac.identity=null
    )

    npm exec electron-builder -- "''${electronBuilderArgs[@]}"
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString isDarwin ''
    mkdir -p $out/Applications $out/bin

    cp -R build/mac*/*.app $out/Applications/SiYuan.app

    cat > $out/bin/siyuan << EOF
    #!${stdenv.shell}
    exec open -na "$out/Applications/SiYuan.app" --args "\$@"
    EOF
    chmod +x $out/bin/siyuan
  ''
  + lib.optionalString isLinux ''
    mkdir -p $out/share/siyuan

    cp -r build/*-unpacked/{locales,resources{,.pak}} $out/share/siyuan

    makeWrapper ${lib.getExe electron} $out/bin/siyuan \
        --chdir $out/share/siyuan/resources \
        --add-flags $out/share/siyuan/resources/app \
        --set ELECTRON_FORCE_IS_PACKAGED 1 \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
        --inherit-argv0

    install -Dm644 src/assets/icon.svg $out/share/icons/hicolor/scalable/apps/siyuan.svg
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = lib.optional isLinux (makeDesktopItem {
    categories = [ "Utility" ];
    comment = "Refactor your thinking";
    desktopName = "SiYuan";
    exec = "siyuan %U";
    icon = "siyuan";
    name = "siyuan";
  });

  kernel = buildGoModule {
    inherit (finalAttrs) src;

    patches = [
      (replaceVars ./set-pandoc-path.patch {
        pandoc_path = lib.getExe pandoc;
      })
    ];

    vendorHash = "sha256-fZLVqrWTWUHo6BhixB6+krXaM7WCiZpusHA8T2SicgQ=";

    # Set flags and tags as per upstream's Dockerfile
    ldflags = [
      "-s"
      "-X 'github.com/siyuan-note/siyuan/kernel/util.Mode=prod'"
    ];

    # this patch makes it so that file permissions are not kept when copying files using the gulu package
    # this fixes a problem where it was copying files from the store and keeping their permissions
    # hopefully this doesn't break other functionality
    modPostBuild = ''
      chmod +w vendor/github.com/88250/gulu
      substituteInPlace vendor/github.com/88250/gulu/file.go \
          --replace-fail "os.Chmod(dest, sourceinfo.Mode())" "os.Chmod(dest, 0644)"
    '';

    name = "${finalAttrs.pname}-${finalAttrs.version}-kernel";
    sourceRoot = "${finalAttrs.src.name}/kernel";
    tags = [ "fts5" ];
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-1QIGx0Zm6v4FIR1EYgXQzmBMZBa9Bi24vouT1K6v9EQ=";
  };

  sourceRoot = "${finalAttrs.src.name}/app";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v(\\d+\\.\\d+\\.\\d+)$"
      "--subpackage=kernel"
    ];
  };

  meta = {
    description = "Privacy-first personal knowledge management system that supports complete offline usage, as well as end-to-end encrypted data sync";
    homepage = "https://b3log.org/siyuan/";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      tomasajt
      ltrump
      myul
    ];

    platforms = lib.attrNames platformIds;
    mainProgram = "siyuan";
  };
})
