{
  lib,
  fetchurl,
  cacert,
  common-updater-scripts,
  curl,
  gnugrep,
  re-plistbuddy,
  stdenvNoCC,
  unzip,
  versionCheckHook,
  writeShellApplication,
  writeShellScript,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rapidapi";
  version = "4.5.5-4005005001";

  src = fetchurl {
    url = "https://cdn-builds.paw.cloud/paw/RapidAPI-${finalAttrs.version}.zip";
    hash = "sha256-1UR7Lj/4fdhwYIvlWjso8tGDO+0sH8XkiysXN2i6/78=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    unzip -d $out/Applications $src

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;
  dontUnpack = true;
  sourceRoot = "RapidAPI.app";

  versionCheckProgram = writeShellScript "version-check" ''
    marketing_version=$(${lib.getExe' re-plistbuddy "PlistBuddy"} -c "Print :CFBundleShortVersionString" "$1")
    build_version=$(${lib.getExe' re-plistbuddy "PlistBuddy"} -c "Print :CFBundleVersion" "$1")
    echo $marketing_version-$build_version
  '';

  versionCheckProgramArg = [ "${placeholder "out"}/Applications/RapidAPI.app/Contents/Info.plist" ];

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "rapidapi-update-script";

    runtimeInputs = [
      curl
      cacert
      gnugrep
      common-updater-scripts
    ];

    text = ''
      url="https://paw.cloud/download"
      version=$(curl -Ls -o /dev/null -w "%{url_effective}" "$url" | grep -oP '\d+\.\d+\.\d+-\d+')
      update-source-version rapidapi "$version"
    '';
  });

  meta = {
    description = "Full-featured HTTP client that lets you test and describe the APIs you build or consume";
    homepage = "https://paw.cloud";
    changelog = "https://paw.cloud/updates/${lib.head (lib.splitString "-" finalAttrs.version)}";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ DimitarNestorov ];

    platforms = [
      "aarch64-darwin"
    ];
  };
})
