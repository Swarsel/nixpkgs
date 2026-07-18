{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  bintools-unwrapped,
  cups,
  installShellFiles,
  llvmPackages,
  nix-update-script,
  versionCheckHook,
  xxd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "yabai";
  version = "7.1.25";

  src = fetchFromGitHub {
    owner = "asmvik";
    repo = "yabai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-61knfbahxxlJnVZy47347slsjUGiQUJyZh58G97SDkE=";
  };

  # yabai's makefile builds universal (x86_64 + arm64/arm64e) binaries with
  # `xcrun clang`. Collapse it to the host arch and use plain `clang`, since the
  # scripting addition (arm64e) is compiled in preBuild with the unwrapped clang,
  # which needs the SDK/clang/CUPS include paths passed explicitly.
  postPatch =
    let
      arch = stdenv.hostPlatform.darwinArch;
      # The scripting addition is injected into arm64e system processes, so on
      # aarch64 it must be arm64e even though the main binary stays arm64.
      archSA = "${arch}${lib.optionalString stdenv.hostPlatform.isAarch64 "e"}";
      clangFlags = lib.concatStringsSep " " [
        "-isystem $(SDKROOT)/usr/include"
        "-isystem ${llvmPackages.libclang.lib}/lib/clang/*/include"
        "-isystem ${lib.getDev cups}/include"
        "-F$(SDKROOT)/System/Library/Frameworks"
        "-L$(SDKROOT)/usr/lib"
        "-Wl,-no_uuid"
      ];
    in
    ''
      substituteInPlace makefile \
        --replace-fail "-arch x86_64 -arch arm64e" "-arch ${archSA}" \
        --replace-fail "-arch x86_64 -arch arm64" "-arch ${arch}" \
        --replace-fail 'xcrun clang' 'clang ${clangFlags}'
    '';

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    xxd
    # TODO: Clean up on `staging`.
    llvmPackages.lld
  ];

  buildInputs = [
    apple-sdk_15
  ];

  # TODO: Clean up on `staging`.
  env.NIX_CFLAGS_LINK = "-fuse-ld=lld";

  # The cc-wrapper can't target arm64e, so build the scripting addition (the only
  # arm64e part) with the unwrapped clang.
  preBuild = lib.optionalString stdenv.hostPlatform.isAarch64 ''
    make ./src/osax/payload_bin.c ./src/osax/loader_bin.c "PATH=${bintools-unwrapped}/bin:${llvmPackages.clang-unwrapped}/bin:$PATH"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/icons/hicolor/scalable/apps}

    cp ./bin/yabai $out/bin/yabai
    cp ./assets/icon/icon.svg $out/share/icons/hicolor/scalable/apps/yabai.svg
    installManPage ./doc/yabai.1

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  # Upstream Makefile races clean-build against linking under parallel make.
  enableParallelBuilding = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tiling window manager for macOS based on binary space partitioning";

    longDescription = ''
      yabai is a window management utility that is designed to work as an extension to the built-in
      window manager of macOS. yabai allows you to control your windows, spaces and displays freely
      using an intuitive command line interface and optionally set user-defined keyboard shortcuts
      using skhd and other third-party software.
    '';

    homepage = "https://github.com/asmvik/yabai";
    changelog = "https://github.com/asmvik/yabai/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];

    maintainers = with lib.maintainers; [
      cmacrae
      khaneliman
    ];

    platforms = lib.platforms.darwin;
    mainProgram = "yabai";
  };
})
