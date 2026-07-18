{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  clang,
  dotnetCorePackages,
  nix-update-script,
  patchelf,
  systemd,
  zlib,
}:

buildDotnetModule rec {
  pname = "crossmacro-daemon";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "alper-han";
    repo = "CrossMacro";
    tag = "v${version}";
    hash = "sha256-lMXp7ItwpZ14ATRKuR7Q8/FhfMNQ+YCgHL13oj6iBNs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    clang
    patchelf
  ];

  buildInputs = [
    systemd
    zlib
  ];

  postInstall = ''
    install -Dm644 scripts/assets/io.github.alper_han.crossmacro.policy \
      $out/share/polkit-1/actions/io.github.alper_han.crossmacro.policy

    install -Dm644 scripts/assets/50-crossmacro.rules \
      $out/share/polkit-1/rules.d/50-crossmacro.rules
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-needed libsystemd.so.0 $out/lib/crossmacro-daemon/CrossMacro.Daemon
  '';

  buildType = "Release";
  dotnet-runtime = null;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnetFlags = [ "-p:Version=${version}" ];
  executables = [ "CrossMacro.Daemon" ];
  nugetDeps = ./deps.json;
  projectFile = "src/CrossMacro.Daemon/CrossMacro.Daemon.csproj";
  selfContainedBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Privileged input daemon for CrossMacro";
    homepage = "https://github.com/alper-han/CrossMacro";
    changelog = "https://github.com/alper-han/CrossMacro/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ alper-han ];
    platforms = lib.platforms.linux;
    mainProgram = "CrossMacro.Daemon";
  };
}
