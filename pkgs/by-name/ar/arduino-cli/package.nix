{
  lib,
  stdenv,
  fetchFromGitHub,
  buildFHSEnv,
  buildGoModule,
  go-task,
  installShellFiles,
  makeWrapper,
  python3,
  writableTmpDirAsHomeHook,
}:

let

  pkg = buildGoModule (finalAttrs: {
    pname = "arduino-cli";
    version = "1.5.1";

    src = fetchFromGitHub {
      owner = "arduino";
      repo = "arduino-cli";
      tag = "v${finalAttrs.version}";
      hash = "sha256-MZX6ERZwmfiJMqx6mQ0qAfv1dbXunTYHRbdzyoinOJY=";
    };

    postPatch =
      let
        skipTests = [
          # tries to "go install"
          "TestDummyMonitor"
          # try to Get "https://downloads.arduino.cc/libraries/library_index.tar.bz2"
          "TestDownloadAndChecksums"
          "TestParseArgs"
          "TestParseReferenceCores"
          "TestPlatformSearch"
          "TestPlatformSearchSorting"
        ];
      in
      ''
        substituteInPlace Taskfile.yml \
          --replace-fail "go test" "go test -p $NIX_BUILD_CORES -skip '(${lib.concatStringsSep "|" skipTests})'"
      '';

    nativeBuildInputs = [
      installShellFiles
      makeWrapper
      writableTmpDirAsHomeHook
    ];

    vendorHash = "sha256-j5SpZnBWcC8K8lHgc5HOCbGD3DdHr9tVtEhXWTCCogk=";
    doCheck = stdenv.hostPlatform.isLinux;
    nativeCheckInputs = [ go-task ];

    checkPhase = ''
      runHook preCheck
      task go:test
      runHook postCheck
    '';

    postInstall = ''
      wrapProgram $out/bin/arduino-cli --prefix PATH : ${lib.makeBinPath [ python3 ]}
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd arduino-cli \
        --bash <($out/bin/arduino-cli completion bash) \
        --zsh <($out/bin/arduino-cli completion zsh) \
        --fish <($out/bin/arduino-cli completion fish)
    '';

    ldflags = [
      "-s"
      "-w"
      "-X github.com/arduino/arduino-cli/internal/version.versionString=${finalAttrs.version}"
      "-X github.com/arduino/arduino-cli/internal/version.commit=unknown"
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ "-extldflags '-static'" ];

    subPackages = [ "." ];

    meta = {
      inherit (finalAttrs.src.meta) homepage;
      description = "Arduino from the command line";
      changelog = "https://github.com/arduino/arduino-cli/releases/tag/${finalAttrs.src.tag}";

      license = with lib.licenses; [
        gpl3Only
        asl20
      ];

      maintainers = with lib.maintainers; [
        ryantm
        sfrijters
      ];

      mainProgram = "arduino-cli";
    };

  });

in
if stdenv.hostPlatform.isLinux then
  # buildFHSEnv is needed because the arduino-cli downloads compiler
  # toolchains from the internet that have their interpreters pointed at
  # /lib64/ld-linux-x86-64.so.2
  buildFHSEnv {
    inherit (pkg) pname version meta;

    extraInstallCommands = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      cp -r ${pkg.outPath}/share $out/share
    '';

    runScript = "${pkg.outPath}/bin/arduino-cli";
    targetPkgs = pkgs: with pkgs; [ zlib ];
    passthru.pureGoPkg = pkg;
  }
else
  pkg
