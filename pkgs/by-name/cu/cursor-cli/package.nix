{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

let
  inherit (stdenv) hostPlatform;
  sources = {
    aarch64-darwin = fetchurl {
      hash = "sha256-UO8SRA6depwO9SNhvYl9uOy9Dp625vHVNiyfxtmq3c4=";
      url = "https://downloads.cursor.com/lab/2026.06.26-7079533/darwin/arm64/agent-cli-package.tar.gz";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-WcMurHV8Pm/2Y1HvNJGZYqjgt3OzHwn5oW5W27egueE=";
      url = "https://downloads.cursor.com/lab/2026.06.26-7079533/linux/arm64/agent-cli-package.tar.gz";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-fZNlWkdPQsK12SfmKmG+VrxWA4Df7sAFQJ5DSToq+Eg=";
      url = "https://downloads.cursor.com/lab/2026.06.26-7079533/linux/x64/agent-cli-package.tar.gz";
    };
  };
in
stdenv.mkDerivation {
  pname = "cursor-cli";
  version = "0-unstable-2026-06-26";
  src = sources.${hostPlatform.system};

  nativeBuildInputs = lib.optionals hostPlatform.isLinux [
    autoPatchelfHook
    stdenv.cc.cc.lib
  ];

  buildInputs = lib.optionals hostPlatform.isLinux [
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/cursor-agent
    cp -r * $out/share/cursor-agent/
    ln -s $out/share/cursor-agent/cursor-agent $out/bin/cursor-agent

    runHook postInstall
  '';

  passthru = {
    inherit sources;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Cursor CLI";
    homepage = "https://cursor.com/cli";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      sudosubin
      andrewbastin
    ];

    platforms = builtins.attrNames sources;
    mainProgram = "cursor-agent";
  };
}
