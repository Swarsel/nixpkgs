{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  bash,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  fontconfig,
  icu,
  krb5,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  lttng-ust_2_12,
  makeDesktopItem,
  nix-update-script,
  openssl,
  zlib,
}:

buildDotnetModule (finalAttrs: {
  pname = "v2rayn";
  version = "7.22.2";

  src = fetchFromGitHub {
    owner = "2dust";
    repo = "v2rayN";
    tag = finalAttrs.version;
    hash = "sha256-MRhJ5l+G97mBBRQzir2s5TQhgzuIeGnOIFszVK1po3w=";
    fetchSubmodules = true;
  };

  postPatch = ''
    chmod +x v2rayN/ServiceLib/Sample/proxy_set_linux_sh
    patchShebangs v2rayN/ServiceLib/Sample/proxy_set_linux_sh
    chmod +x v2rayN/ServiceLib/Sample/kill_as_sudo_linux_sh
    patchShebangs v2rayN/ServiceLib/Sample/kill_as_sudo_linux_sh
    substituteInPlace v2rayN/ServiceLib/Global.cs \
      --replace-fail "/bin/bash" "${lib.getExe bash}"
    substituteInPlace v2rayN/ServiceLib/Manager/CoreAdminManager.cs \
      --replace-fail "/bin/bash" "${lib.getExe bash}"
    substituteInPlace v2rayN/ServiceLib/Handler/AutoStartupHandler.cs \
      --replace-fail "Utils.GetExePath())" '"v2rayN")'
    substituteInPlace v2rayN/ServiceLib/Manager/CoreManager.cs \
      --replace-fail 'Environment.GetEnvironmentVariable(Global.LocalAppData) == "1"' "false"
  '';

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    fontconfig
    icu
    openssl
    krb5
    lttng-ust_2_12
    (lib.getLib stdenv.cc.cc)
  ];

  postInstall = ''
    install -D --mode 0644 v2rayN/v2rayN.Desktop/v2rayN.png $out/share/icons/hicolor/256x256/apps/v2rayn.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      comment = "A GUI client for Windows and Linux, support Xray core and sing-box-core and others";
      desktopName = "v2rayN";
      exec = "v2rayN";
      genericName = "v2rayN";
      icon = "v2rayn";
      name = "v2rayn";
      terminal = false;
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnetBuildFlags = [ "-p:PublishReadyToRun=false" ];
  executables = [ "v2rayN" ];
  nugetDeps = ./deps.json;
  projectFile = "v2rayN/v2rayN.Desktop/v2rayN.Desktop.csproj";

  runtimeDeps = [
    libx11
    libxrandr
    libxi
    libice
    libsm
    libxcursor
    libxext
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI client support Xray core and sing-box-core and others";
    homepage = "https://github.com/2dust/v2rayN";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "v2rayN";
  };
})
