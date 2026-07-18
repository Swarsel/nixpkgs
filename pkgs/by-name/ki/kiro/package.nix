{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  buildVscode,
  extraCommandLineArgs ? "",
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
}:

let
  sources = (lib.importJSON ./sources.json).${stdenv.hostPlatform.system};
in
(buildVscode {
  inherit useVSCodeRipgrep;
  pname = "kiro";
  version = "0.12.333";

  src = fetchurl {
    url = sources.url;
    hash = sources.hash;
  };

  commandLineArgs = extraCommandLineArgs;
  dontFixup = stdenv.hostPlatform.isDarwin;
  executableName = "kiro";
  # Kiro.dmg is APFS formatted, unpack with 7zz
  extraNativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ _7zz ];
  iconName = "kiro";
  libraryName = "kiro";
  longName = "Kiro";
  patchVSCodePath = true;
  shortName = "kiro";
  sourceExecutableName = if stdenv.hostPlatform.isDarwin then "code" else "kiro";
  sourceRoot = if stdenv.hostPlatform.isDarwin then "Kiro.app" else "Kiro";
  tests = { };
  updateScript = ./update.sh;
  # You can find the current VSCode version in the About dialog:
  # workbench.action.showAboutDialog (Help: About)
  vscodeVersion = "1.107.1";

  meta = {
    description = "IDE for Agentic AI workflows based on VS Code";
    homepage = "https://kiro.dev";
    license = lib.licenses.amazonsl;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      vuks
      jamesward
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "kiro";
  };

}).overrideAttrs
  (oldAttrs: {
    passthru = (oldAttrs.passthru or { }) // {
      inherit sources;
    };
  })
