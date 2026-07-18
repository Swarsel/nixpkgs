{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchPnpmDeps,
  installShellFiles,
  nix-update-script,
  nixosTests,
  nodejs-slim,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:

let
  version = "2.63.15";

  src = fetchFromGitHub {
    owner = "filebrowser";
    repo = "filebrowser";
    tag = "v${version}";
    hash = "sha256-O2USjwP1g+yDZpz0628YTRN2BUUnmjFvS+0qc6JU294=";
  };

  frontend = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version src;
    pname = "filebrowser-frontend";

    nativeBuildInputs = [
      nodejs-slim
      pnpmConfigHook
      pnpmBuildHook
      pnpm_10
    ];

    installPhase = ''
      runHook preInstall

      mkdir $out
      mv dist $out

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 3;
      hash = "sha256-UwTA7Eogp2GrvmXDbdfGBTJS3DuOTJ42e6fHlQxSHoA=";
      pnpm = pnpm_10;
    };

    sourceRoot = "${src.name}/frontend";
  });

in
buildGoModule {
  inherit version src;
  pname = "filebrowser";
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-WXbXD75acK4woS7UC0G73pY48aGmp1l0spDc3sGYXMg=";

  preBuild = ''
    cp -r ${frontend}/dist frontend/
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd filebrowser \
      --bash <($out/bin/filebrowser completion bash) \
      --fish <($out/bin/filebrowser completion fish) \
      --zsh  <($out/bin/filebrowser completion zsh )
  '';

  excludedPackages = [ "tools" ];

  ldflags = [
    "-X github.com/filebrowser/filebrowser/v2/version.Version=v${version}"
  ];

  passthru = {
    inherit frontend;

    tests = {
      inherit (nixosTests) filebrowser;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "frontend"
      ];
    };
  };

  meta = {
    description = "Web application for managing files and directories";
    homepage = "https://filebrowser.org";
    changelog = "https://github.com/filebrowser/filebrowser/releases/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ oakenshield ];
    mainProgram = "filebrowser";
  };
}
