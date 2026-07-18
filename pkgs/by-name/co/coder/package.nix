{
  lib,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
  nixosTests,
  stdenvNoCC,
  terraform,
  unzip,
  channel ? "stable",
}:

let
  inherit (stdenvNoCC.hostPlatform) system;

  channels = {
    mainline = {
      version = "2.34.5";

      hash = {
        aarch64-darwin = "sha256-VhliikNdqi7AauYlKQvMroEjR3jZZnhNw0HTtJFw5zg=";
        aarch64-linux = "sha256-UDyEhBAlvgSHWLPtbNXHj6X2gle1Y3fjQLSKHzwc/XI=";
        x86_64-linux = "sha256-B0roCJqTu6o89nHbVA3b9eHKj/VmJ9i1j4blF1I76yU=";
      };
    };

    stable = {
      version = "2.33.11";

      hash = {
        aarch64-darwin = "sha256-7A6BxOg4A3Ua5SXjnh5gtG/LE94iGuRQPe/S9UjX/oc=";
        aarch64-linux = "sha256-Wc9hhotJKcb1fdjfh9pWxVs/e4YpBua1PyAhMRJbUAY=";
        x86_64-linux = "sha256-NY9xyLc6Pr1wWPnr4fLo6t+7B7Gin/BlTH3tdxQk30k=";
      };
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "coder";
  version = channels.${channel}.version;

  src = fetchurl {
    url =
      let
        systemName =
          {
            aarch64-darwin = "darwin_arm64";
            aarch64-linux = "linux_arm64";
            x86_64-linux = "linux_amd64";
          }
          .${system};

        ext =
          {
            aarch64-darwin = "zip";
            aarch64-linux = "tar.gz";
            x86_64-linux = "tar.gz";
          }
          .${system};
      in
      "https://github.com/coder/coder/releases/download/v${finalAttrs.version}/coder_${finalAttrs.version}_${systemName}.${ext}";

    hash = (channels.${channel}.hash).${system};
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
    unzip
  ];

  # integration tests require network access
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -D -m755 coder $out/bin/coder

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/coder \
      --prefix PATH : ${lib.makeBinPath [ terraform ]}
  '';

  unpackPhase = ''
    runHook preUnpack

    case $src in
        *.tar.gz) tar -xz -f "$src" ;;
        *.zip)    unzip      "$src" ;;
    esac

    runHook postUnpack
  '';

  passthru = {
    tests = {
      inherit (nixosTests) coder;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Provision remote development environments via Terraform";
    homepage = "https://coder.com";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      bpmct
      developmentcats
      kylecarbs
      phorcys420
    ];

    mainProgram = "coder";
  };
})
