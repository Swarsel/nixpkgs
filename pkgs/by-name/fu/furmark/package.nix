{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  libGL,
  libGLU,
  libxcrypt-legacy,
  makeDesktopItem,
  makeWrapper,
  p7zip,
  testers,
  vulkan-loader,
}:

let
  description = "OpenGL and Vulkan Benchmark and Stress Test";

  versions = {
    "aarch64-linux" = "2.10.1";
    "i686-linux" = "2.0.16";
    "x86_64-linux" = "2.10.2";
  };

  sources = {
    "aarch64-linux" = {
      hash = "sha256-XQuK6UgZOjwqpENkHVYsoiG9zyZAbNjR+65hj9dvAY8=";
      url = "https://gpumagick.com/downloads/files/2025/fm2/2_10_dbc69dd0a08da5ff09169a4fc759ddaa/FurMark_${versions.aarch64-linux}_arm64.7z";
    };

    "i686-linux" = {
      hash = "sha256-yXd90FgL3WbTga5x0mXT40BonA2NQtqLzRVzn4s4lLc=";
      url = "https://gpumagick.com/downloads/files/2024/furmark2/FurMark_${versions.i686-linux}_linux32.zip";
    };

    "x86_64-linux" = {
      hash = "sha256-s9AEj9r7kBhPGPU365HgxS9tEyrm7UjLtoxD21pCrts=";
      url = "https://gpumagick.com/downloads/files/2025/fm2/2_10_dbc69dd0a08da5ff09169a4fc759ddaa/FurMark_${versions.x86_64-linux}_linux64.7z";
    };
  };

  is7z =
    (stdenv.hostPlatform.system == "x86_64-linux") || (stdenv.hostPlatform.system == "aarch64-linux");

  linkLogs =
    (stdenv.hostPlatform.system == "x86_64-linux") || (stdenv.hostPlatform.system == "aarch64-linux");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "furmark";

  version =
    versions.${stdenv.hostPlatform.system}
      or (throw "Furmark is not available on ${stdenv.hostPlatform.system}");

  src = fetchurl sources.${stdenv.hostPlatform.system};

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    p7zip
  ];

  buildInputs = [
    libGL
    libGLU
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [ libxcrypt-legacy ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/furmark
    cp -rp * $out/share/furmark
  ''
  + lib.optionalString linkLogs ''
    ln -sf /tmp/furmark-geexlab.log $out/share/furmark/_geexlab_log.txt
    ln -sf /tmp/furmark-furmark.log $out/share/furmark/_furmark_log.txt
  ''
  + ''
    mkdir -p $out/bin
    for i in $(find $out/share/furmark -maxdepth 1 -type f -executable); do
      ln -s "$i" "$out/bin/$(basename "$i")"
    done

    runHook postInstall
  '';

  appendRunpaths = [ (lib.makeLibraryPath [ vulkan-loader ]) ];

  desktopItems = [
    (makeDesktopItem rec {
      categories = [
        "System"
        "Monitor"
      ];

      comment = description;
      desktopName = name;
      exec = "FurMark_GUI";
      genericName = name;

      icon = fetchurl {
        hash = "sha256-EqhWQgTEmF/2AcqDxgGtr2m5SMYup28hPEhI6ssFw7g=";
        url = "https://www.geeks3d.com/furmark/i/20240220-furmark-logo-02.png";
      };

      name = "FurMark";
    })
  ];

  unpackPhase = ''
    runHook preUnpack
    7z x $src
  ''
  + lib.optionalString is7z ''
    mv FurMark_linux64/* .
    rmdir FurMark_linux64
  ''
  + ''
    runHook postUnpack
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "furmark --version";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    inherit description;
    homepage = "https://www.geeks3d.com/furmark/v2/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      surfaceflinger
      w1lldu
    ];

    platforms = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "FurMark_GUI";
  };
})
