{
  lib,
  stdenv,
  fetchurl,
  buildVscode,
  nixosTests,
  srcOnly,
  stdenvNoCC,
  commandLineArgs ? "",
  isInsiders ? false,
  # sourceExecutableName is the name of the binary in the source archive over
  # which we have no control and it is needed to run the insider version as
  # documented in https://wiki.nixos.org/wiki/Visual_Studio_Code#Insiders_Build
  # On MacOS the insider binary is still called code instead of code-insiders as
  # of 2023-08-06.
  sourceExecutableName ?
    "code" + lib.optionalString (isInsiders && stdenv.hostPlatform.isLinux) "-insiders",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      aarch64-darwin = "darwin-arm64";
      aarch64-linux = "linux-arm64";
      armv7l-linux = "linux-armhf";
      x86_64-linux = "linux-x64";
    }
    .${system} or throwSystem;

  archive_fmt = if stdenv.hostPlatform.isDarwin then "zip" else "tar.gz";

  hash =
    {
      aarch64-darwin = "sha256-IHu9EwW9/oS2FTr/mB7ugMss5Pku3IyslqFYr4riZyk=";
      aarch64-linux = "sha256-UEkpGlTV/KZ8Qcw/OBOCNDQHblD7gHHloSzM62FvDnw=";
      armv7l-linux = "sha256-Rfp2H6L7bXXhdxf2yphW9YXDGW1+Ea0nKdyTFS8Y/tU=";
      x86_64-linux = "sha256-4G+zZ5HJuvdJXUt9wPWqqCVOfRpgpe5D5sfevAXJYrU=";
    }
    .${system} or throwSystem;

  # Please backport all compatible updates to the stable release.
  # This is important for the extension ecosystem.
  version = "1.127.0";

  # The update server (update.code.visualstudio.com) expects the version path
  # segment in X.Y.Z form, so we normalize X.Y to X.Y.0 (e.g. "1.110" → "1.110.0").
  # Upstream GitHub release tags may use X.Y, which is why this normalization is needed.
  downloadVersion = lib.versions.pad 3 version;

  # This is used for VS Code - Remote SSH test
  rev = "4fe60c8b1cdac1c4c174f2fb180d0d758272d713";
in
buildVscode {
  inherit
    version
    rev
    commandLineArgs
    useVSCodeRipgrep
    sourceExecutableName
    ;

  pname = "vscode" + lib.optionalString isInsiders "-insiders";

  src = fetchurl {
    inherit hash;
    url = "https://update.code.visualstudio.com/${downloadVersion}/${plat}/stable";
    name = "VSCode_${downloadVersion}_${plat}.${archive_fmt}";
  };

  # Editing the `code` binary within the app bundle causes the bundle's signature
  # to be invalidated, which prevents launching starting with macOS Ventura, because VS Code is notarized.
  # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
  dontFixup = stdenv.hostPlatform.isDarwin;
  executableName = "code" + lib.optionalString isInsiders "-insiders";
  hasVsceSign = true;
  longName = "Visual Studio Code" + lib.optionalString isInsiders " - Insiders";
  shortName = "Code" + lib.optionalString isInsiders " - Insiders";
  sourceRoot = "";
  # We don't test vscode on CI, instead we test vscodium
  tests = { };
  tests = { inherit (nixosTests) vscode-remote-ssh; };
  updateScript = ./update-vscode.sh;

  # As tests run without networking, we need to download this for the Remote SSH server
  vscodeServer = srcOnly {
    src = fetchurl {
      url = "https://update.code.visualstudio.com/commit:${rev}/server-linux-x64/stable";
      hash = "sha256-JpcbzKdVlfRRKCzG/aDoWEGG7Yg0BcjuqCcg/Nez/9U=";
      name = "vscode-server-${rev}.tar.gz";
    };

    name = "vscode-server-${rev}.tar.gz";
    stdenv = stdenvNoCC;
  };

  meta = {
    description = "Code editor developed by Microsoft";

    longDescription = ''
      Code editor developed by Microsoft. It includes support for debugging,
      embedded Git control, syntax highlighting, intelligent code completion,
      snippets, and code refactoring. It is also customizable, so users can
      change the editor's theme, keyboard shortcuts, and preferences
    '';

    homepage = "https://code.visualstudio.com/";

    changelog = "https://code.visualstudio.com/updates/v${
      lib.replaceString "." "_" (lib.versions.majorMinor version)
    }";

    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      eadwu
      bobby285271
      johnrtitor
      jefflabonte
      wetrustinprize
      oenu
      yuannan
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
      "armv7l-linux"
    ];

    mainProgram = "code";
    downloadPage = "https://code.visualstudio.com/Updates";
  };
}
