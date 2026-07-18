{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  installShellFiles,
  makeBinaryWrapper,
  nix,
  python3Packages,
  # tests
  testers,
  # update script
  writers,
  withShellCompletions ? stdenv.hostPlatform.emulatorAvailable buildPackages,
}:
let
  pname = "yandex-cloud";
  sources = lib.importJSON ./sources.json;
  inherit (sources) version binaries;
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;
  src = fetchurl binaries.${stdenv.hostPlatform.system};
  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p -- "$out/bin"
    cp -- "$src" "$out/bin/yc"
    chmod +x -- "$out/bin/yc"
  ''
  + lib.optionalString withShellCompletions ''
    for shell in bash zsh; do
      ''${emulator:+"$emulator"} "$out/bin/yc" completion $shell >yc.$shell
      installShellCompletion yc.$shell
    done
  ''
  + ''
    makeWrapper "$out/bin/yc" "$out/bin/docker-credential-yc" \
      --add-flags --no-user-output \
      --add-flags container \
      --add-flags docker-credential
    runHook postInstall
  '';

  dontUnpack = true;

  emulator = lib.optionalString (
    withShellCompletions && !stdenv.buildPlatform.canExecute stdenv.hostPlatform
  ) (stdenv.hostPlatform.emulator buildPackages);

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

    updateScript = writers.writePython3 "${pname}-updater" {
      libraries = with python3Packages; [ requests ];

      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath [ nix ])
      ];
    } ./update.py;
  };

  meta = {
    description = "Command line interface that helps you interact with Yandex Cloud services";
    homepage = "https://cloud.yandex/docs/cli";
    changelog = "https://cloud.yandex/docs/cli/release-notes#version${version}";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.tie ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
      # Built with GO386=sse2.
      #
      # Unfortunately, we don’t have anything about SSE2 support in lib.systems,
      # so we can’t mark this a broken or bad platform if host platform does not
      # support SSE2. See also https://github.com/NixOS/nixpkgs/issues/132217
      #
      # Perhaps it would be possible to mark it as broken if platform declares
      # GO386=softfloat once https://github.com/NixOS/nixpkgs/pull/256761 is
      # ready and merged.
      "i686-linux"
    ];

    mainProgram = "yc";
  };
})
