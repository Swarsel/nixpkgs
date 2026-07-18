{
  lib,
  stdenv,
  fetchFromGitHub,
  autoSignDarwinBinariesHook,
  bintools,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  fixDarwinDylibNames,
  fontconfig,
  glew,
  icoutils,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  makeDesktopItem,
}:

buildDotnetModule rec {
  pname = "avalonia-ilspy";
  version = "7.2-rc";

  src = fetchFromGitHub {
    owner = "icsharpcode";
    repo = "AvaloniaILSpy";
    rev = "v${version}";
    hash = "sha256-cCQy5cSpJNiVZqgphURcnraEM0ZyXGhzJLb5AThNfPQ=";
  };

  patches = [
    # Remove dead nuget package source
    ./remove-broken-sources.patch
    # Upgrade project to .NET 8.0
    ./dotnet-8-upgrade.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    icoutils
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    bintools
    fixDarwinDylibNames
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    autoSignDarwinBinariesHook
  ];

  buildInputs = [
    # Dependencies of nuget packages w/ native binaries
    (lib.getLib stdenv.cc.cc)
    fontconfig
  ];

  postInstall = ''
    icotool --icon -x ILSpy/ILSpy.ico
    for i in 16 32 48 256; do
      size=''${i}x''${i}
      install -Dm444 *_''${size}x32.png $out/share/icons/hicolor/$size/apps/ILSpy.png
    done
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install -Dm444 ILSpy/Info.plist $out/Applications/ILSpy.app/Contents/Info.plist
    install -Dm444 ILSpy/ILSpy.icns $out/Applications/ILSpy.app/Contents/Resources/ILSpy.icns
    mkdir -p $out/Applications/ILSpy.app/Contents/MacOS
    ln -s $out/bin/ILSpy $out/Applications/ILSpy.app/Contents/MacOS/ILSpy
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
      ];

      comment = ".NET assembly browser and decompiler";
      desktopName = "ILSpy";
      exec = "ILSpy";
      icon = "ILSpy";

      keywords = [
        ".net"
        "il"
        "assembly"
      ];

      name = "ILSpy";
    })
  ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "ILSpy" ];
  nugetDeps = ./deps.json;
  projectFile = "ILSpy/ILSpy.csproj";

  runtimeDeps = [
    # Avalonia UI
    libx11
    libice
    libsm
    libxi
    libxcursor
    libxext
    libxrandr
    fontconfig
    glew
  ];

  meta = {
    description = ".NET assembly browser and decompiler";
    homepage = "https://github.com/icsharpcode/AvaloniaILSpy";

    license = with lib.licenses; [
      mit
      # third party dependencies
      lgpl21Only
      mspl
    ];

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [
      AngryAnt
      emilytrau
    ];

    mainProgram = "ILSpy";
  };
}
