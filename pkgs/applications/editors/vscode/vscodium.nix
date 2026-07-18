{
  lib,
  stdenv,
  fetchurl,
  buildVscode,
  nixosTests,
  commandLineArgs ? "",
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
      loongarch64-linux = "linux-loong64";
      x86_64-linux = "linux-x64";
    }
    .${system} or throwSystem;

  archive_fmt = if stdenv.hostPlatform.isDarwin then "zip" else "tar.gz";

  hash =
    {
      aarch64-darwin = "sha256-c8K17XKpRG1ji2mUfoyg2+cRF+qc1KVMYVkaQoUIz7Y=";
      aarch64-linux = "sha256-mT5dvw8GOZ0GnZaKRS/TAzQDEEYDOgcj6w6lNLy5kQ0=";
      armv7l-linux = "sha256-91ZHhEUDVoDiRBLwMHVLhzKmb9gWcPBUsVRZVLhCA4M=";
      loongarch64-linux = "sha256-7iUdsIyJkIi40Xn+/PWdCVgahQxbZtiMw0QLMisN+sg=";
      x86_64-linux = "sha256-LJsGc11MH6zlcJNfSWjTWPn2Jp9dkjeBPQuCXH1woUM=";
    }
    .${system} or throwSystem;

  sourceRoot = lib.optionalString (!stdenv.hostPlatform.isDarwin) ".";
in
buildVscode rec {
  inherit sourceRoot commandLineArgs useVSCodeRipgrep;
  pname = "vscodium";
  # Please backport all compatible updates to the stable release.
  # This is important for the extension ecosystem.
  version = "1.121.03429";

  src = fetchurl {
    inherit hash;
    url = "https://github.com/VSCodium/vscodium/releases/download/${version}/VSCodium-${plat}-${version}.${archive_fmt}";
  };

  # Editing the `codium` binary (and shell scripts) within the app bundle causes the bundle's signature
  # to be invalidated, which prevents launching starting with macOS Ventura, because VSCodium is notarized.
  # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
  dontFixup = stdenv.hostPlatform.isDarwin;
  executableName = "codium";
  longName = "VSCodium";
  shortName = "vscodium";
  tests = nixosTests.vscodium.xorg;
  updateScript = ./update-vscodium.sh;
  vscodeVersion = "1.121.0";

  meta = {
    description = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS (VS Code without MS branding/telemetry/licensing)
    '';

    longDescription = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS. It includes support for debugging, embedded Git
      control, syntax highlighting, intelligent code completion, snippets,
      and code refactoring. It is also customizable, so users can change the
      editor's theme, keyboard shortcuts, and preferences
    '';

    homepage = "https://github.com/VSCodium/vscodium";
    changelog = "https://github.com/VSCodium/vscodium/releases/tag/${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      bobby285271
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
      "loongarch64-linux"
    ];

    mainProgram = "codium";
    # requires libc.so.6 and other glibc specifics
    broken = stdenv.hostPlatform.isLinux && !stdenv.hostPlatform.isGnu;
    downloadPage = "https://github.com/VSCodium/vscodium/releases";
  };
}
