{
  lib,
  fetchurl,
  autoPatchelfHook,
  e2fsprogs,
  gccForLibs,
  installShellFiles,
  lz4,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
  versionCheckHook,
  xxhash,
  zlib,
  zstd,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "docker-sbx";
  version = "0.34.0";

  src =
    if stdenvNoCC.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://github.com/docker/sbx-releases/releases/download/v${finalAttrs.version}/DockerSandboxes-linux-amd64.tar.gz";
        hash = "sha256-5H9LOyKi0/SBVJ0ld6OkcP1h9r9eHrAb4fsVVVdMusg=";
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-linux" then
      fetchurl {
        url = "https://github.com/docker/sbx-releases/releases/download/v${finalAttrs.version}/DockerSandboxes-linux-arm64.tar.gz";
        hash = "sha256-dZ/ttnmaf62rA5Cs8YSmZGHVQoy9PQh3Ok/AnIjCqZ4=";
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-darwin" then
      fetchurl {
        url = "https://github.com/docker/sbx-releases/releases/download/v${finalAttrs.version}/DockerSandboxes-darwin.tar.gz";
        hash = "sha256-aBh6NbtQ5o2zxuR+d1U1gZpm2bch/J3Y8GZ73DeUBUk=";
      }
    else
      throw "Unsupported host platform ${stdenvNoCC.hostPlatform.system}";

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
    autoPatchelfHook
    makeWrapper
    e2fsprogs
  ];

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    lz4
    zlib
    zstd
    xxhash
    gccForLibs
  ];

  installPhase =
    if stdenvNoCC.hostPlatform.isLinux then
      ''
        runHook preInstall

        PREFIX=$out bash ./install.sh

        wrapProgram $out/bin/sbx \
          --prefix PATH : ${lib.makeBinPath [ e2fsprogs ]}

        ${lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
          export HOME=$TMPDIR
          $out/bin/sbx completion bash > sbx.bash
          $out/bin/sbx completion fish > sbx.fish
          $out/bin/sbx completion zsh  > sbx.zsh
          installShellCompletion sbx.{bash,fish,zsh}
        ''}

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mkdir -pv $out
        cp -rv bin libexec $out

        installShellCompletion \
          --bash --name sbx.bash completions/bash/sbx \
          --zsh  --name _sbx     completions/zsh/_sbx \
          --fish --name sbx.fish completions/fish/sbx.fish

        runHook postInstall
      '';

  doInstallCheck = true;
  __structuredAttrs = true;
  dontBuild = true;

  preVersionCheck = ''
    export HOME=$TMPDIR
  '';

  sourceRoot = if stdenvNoCC.hostPlatform.isDarwin then "." else null;
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Safe environments for agents";

    longDescription = ''
      Docker Sandboxes provides sandboxes with controlled access to your
      filesystem, network, and tools. This means your agents can work
      autonomously without putting your machine or data at risk.
    '';

    homepage = "https://docs.docker.com/reference/cli/sbx/";
    changelog = "https://github.com/docker/sbx-releases/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;

    maintainers = [
      lib.maintainers.skyesoss
      lib.maintainers.erics118
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "sbx";
  };
})
