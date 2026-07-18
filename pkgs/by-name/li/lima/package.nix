{
  lib,
  stdenv,
  apple-sdk_15,
  buildGoModule,
  callPackage,
  darwin,
  installShellFiles,
  jq,
  lima,
  lima-additional-guestagents,
  llvmPackages,
  makeWrapper,
  nix-update-script,
  qemu,
  runCommand,
  testers,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  writeText,
  withAdditionalGuestAgents ? false,
}:

let
  source = callPackage ./source.nix { };
in
buildGoModule (finalAttrs: {
  inherit (source) version src vendorHash;
  pname = "lima" + lib.optionalString withAdditionalGuestAgents "-full";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'codesign -f -v --entitlements vz.entitlements -s -' 'codesign -f --entitlements vz.entitlements -s -' \
      --replace-fail 'rm -rf _output vendor' 'rm -rf _output'
  '';

  nativeBuildInputs = [
    makeWrapper
    installShellFiles

    # For checkPhase, and installPhase(required to build completion)
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
    # TODO: Remove when NixOS/nixpkgs#536365 reaches master.
    llvmPackages.lld
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk_15 ];

  # TODO: Remove when NixOS/nixpkgs#536365 reaches master.
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=${lib.getExe' llvmPackages.lld "ld64.lld"}";
  };

  buildPhase =
    let
      makeFlags = [
        "VERSION=v${finalAttrs.version}"
        "CC=${stdenv.cc.targetPrefix}cc"
      ];
    in
    ''
      runHook preBuild

      make ${lib.escapeShellArgs makeFlags} native

      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r _output/* $out
    wrapProgram $out/bin/limactl \
      --prefix PATH : ${lib.makeBinPath [ qemu ]}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd limactl \
      --bash <($out/bin/limactl completion bash) \
      --fish <($out/bin/limactl completion fish) \
      --zsh <($out/bin/limactl completion zsh)
  ''
  + ''
    runHook postInstall
  '';

  postInstall = lib.optionalString withAdditionalGuestAgents ''
    cp -rs '${lima-additional-guestagents}/share/lima/.' "$out/share/lima/"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    # Workaround for: "panic: $HOME is not defined" at https://github.com/lima-vm/lima/blob/cb99e9f8d01ebb82d000c7912fcadcd87ec13ad5/pkg/limayaml/defaults.go#L53
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    USER=nix $out/bin/limactl validate templates/default.yaml

    runHook postInstallCheck
  '';

  # It attaches entitlements with codesign and strip removes those,
  # voiding the entitlements and making it non-operational.
  dontStrip = stdenv.hostPlatform.isDarwin;
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgram = "${placeholder "out"}/bin/limactl";

  passthru = {
    tests =
      let
        arch = stdenv.hostPlatform.parsed.cpu.name;
      in
      {
        additionalAgents = testers.testEqualContents {
          actual =
            runCommand "actual"
              {
                nativeBuildInputs = [
                  writableTmpDirAsHomeHook
                  (lima.override {
                    withAdditionalGuestAgents = true;
                  })
                  jq
                ];
              }
              ''
                limactl info | jq '.guestAgents | has("${arch}")' >>"$out"
                limactl info | jq '.guestAgents | length >= 2' >>"$out"
              '';

          assertion = "limactl also detects additional guest agents if specified";

          expected = writeText "expected" ''
            true
            true
          '';
        };

        minimalAgent = testers.testEqualContents {
          actual =
            runCommand "actual"
              {
                nativeBuildInputs = [
                  writableTmpDirAsHomeHook
                  lima
                  jq
                ];
              }
              ''
                limactl info | jq '.guestAgents | has("${arch}")' >>"$out"
                limactl info | jq '.guestAgents | length' >>"$out"
              '';

          assertion = "limactl only detects host's architecture guest agent by default";

          expected = writeText "expected" ''
            true
            1
          '';
        };
      };

    updateScript = nix-update-script {
      extraArgs = [
        "--override-filename"
        ./source.nix
      ];
    };
  };

  meta = source.meta // {
    description = "Linux virtual machines with automatic file sharing and port forwarding";
  };
})
