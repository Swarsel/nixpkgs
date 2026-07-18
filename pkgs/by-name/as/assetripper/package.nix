{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  dbus,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "assetripper";
  version = "1.3.14";

  src = fetchFromGitHub {
    owner = "AssetRipper";
    repo = "AssetRipper";
    tag = finalAttrs.version;
    hash = "sha256-bRz+kvDSPxyt8CNn6sszEcMIxgNNv4FQRFO7zFglPkU=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    dbus
    (lib.getLib stdenv.cc.cc)
  ];

  # Make the main executable available under a more intuitive name.
  postInstall = ''
    mkdir -p $out/bin
    ln -rs $out/bin/AssetRipper.GUI.Free $out/bin/AssetRipper
  '';

  # Prevent automatic patching of all files. This is necessary as applying
  # autoPatchelf indiscriminately causes dangling references to openssl and
  # icu4c in AssetRipper.GUI.Free
  dontAutoPatchelf = true;
  dotnet-runtime = finalAttrs.dotnet-sdk.aspnetcore;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  # Error: "PublishTrimmed is implied by native compilation and cannot be disabled."
  # We need to override the project settings and disable native AoT compilation
  # as this is incompatible with PublishTrimmed.
  dotnetInstallFlags = [ "-p:PublishAot=false" ];
  executables = [ "AssetRipper.GUI.Free" ];

  # Patch some prebuilt libraries fetched via NuGet.
  fixupPhase = lib.optionalString stdenv.hostPlatform.isLinux ''
    runHook preFixup

    autoPatchelf $out/lib/assetripper/libnfd.so
    autoPatchelf $out/lib/assetripper/libTexture2DDecoderNative.so

    runHook postFixup
  '';

  # Avoid IOException on startup
  makeWrapperArgs = [
    "--add-flags"
    "--log=false"
  ];

  nugetDeps = ./deps.json;
  projectFile = "Source/AssetRipper.GUI.Free/AssetRipper.GUI.Free.csproj";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for extracting assets from Unity serialized files and asset bundles";
    homepage = "https://github.com/AssetRipper/AssetRipper";
    license = lib.licenses.gpl3Only;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # libraries fetched by NuGet
    ];

    maintainers = with lib.maintainers; [
      YoshiRulz
      toasteruwu
    ];

    platforms = lib.platforms.unix;
    mainProgram = "AssetRipper";
  };
})
