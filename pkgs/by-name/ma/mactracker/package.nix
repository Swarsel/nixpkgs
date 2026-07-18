{
  lib,
  fetchurl,
  cacert,
  common-updater-scripts,
  curl,
  libxml2,
  re-plistbuddy,
  stdenvNoCC,
  unzip,
  versionCheckHook,
  writeShellApplication,
  writeShellScript,
  xmlstarlet,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mactracker";
  version = "8.2.1";

  src = fetchurl {
    url = "https://mactracker.ca/downloads/Mactracker_${finalAttrs.version}.zip";
    hash = "sha256-c78Bj63nJ+/qejUiD7hBEJlxubmIc+wElazwHGRRyfI=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    unzip -d $out/Applications $src -x '__MACOSX/*'
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;
  dontUnpack = true;
  sourceRoot = "Mactracker.app";

  versionCheckProgram = writeShellScript "version-check" ''
    ${lib.getExe' re-plistbuddy "PlistBuddy"} -c "Print :CFBundleVersion" "$1"
  '';

  versionCheckProgramArg = [ "${placeholder "out"}/Applications/Mactracker.app/Contents/Info.plist" ];

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "mactracker-update-script";

    runtimeInputs = [
      curl
      cacert
      libxml2
      xmlstarlet
      common-updater-scripts
    ];

    text = ''
      url="https://mactracker.ca/releasenotes-mac.html"
      version=$(curl -s "$url" | xmllint -html -xmlout - | xmlstarlet sel -t -v "//faq/h5[1]")
      update-source-version mactracker "$version"
    '';
  });

  meta = {
    description = "Provides detailed information on every Apple Macintosh, iPod, iPhone, iPad, and Apple Watch ever made";
    homepage = "https://mactracker.ca";
    changelog = "https://mactracker.ca/releasenotes-mac.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ DimitarNestorov ];

    platforms = [
      "aarch64-darwin"
    ];
  };
})
