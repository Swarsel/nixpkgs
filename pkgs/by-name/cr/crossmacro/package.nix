{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  expat,
  fontconfig,
  freetype,
  glib,
  icu,
  installShellFiles,
  libglvnd,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  libxtst,
  nix-update-script,
  openssl,
  wayland,
  zlib,
}:

buildDotnetModule rec {
  pname = "crossmacro";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "alper-han";
    repo = "CrossMacro";
    tag = "v${version}";
    hash = "sha256-lMXp7ItwpZ14ATRKuR7Q8/FhfMNQ+YCgHL13oj6iBNs=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage docs/man/crossmacro.1

    install -Dm644 scripts/assets/CrossMacro.desktop $out/share/applications/crossmacro.desktop

    for size in 16 32 48 64 128 256 512; do
      install -Dm644 src/CrossMacro.UI/Assets/icons/''${size}x''${size}/apps/crossmacro.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/crossmacro.png
    done

    install -Dm644 scripts/assets/io.github.alper-han.CrossMacro.metainfo.xml \
      $out/share/metainfo/io.github.alper-han.CrossMacro.metainfo.xml

    mkdir -p $out/bin
    ln -sf $out/bin/CrossMacro.UI $out/bin/crossmacro
  '';

  buildType = "Release";
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetFlags = [
    "-p:SelfContained=false"
    "-p:Version=${version}"
  ];

  executables = [ "CrossMacro.UI" ];
  nugetDeps = ./deps.json;
  projectFile = "src/CrossMacro.UI.Linux/CrossMacro.UI.Linux.csproj";

  runtimeDeps = [
    zlib
    icu
    openssl
    fontconfig
    freetype
    expat
    libx11
    libice
    libsm
    libxi
    libxcursor
    libxext
    libxrandr
    libxtst
    glib
    libglvnd
    wayland
    libxkbcommon
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform mouse and keyboard macro recorder and player";
    homepage = "https://github.com/alper-han/CrossMacro";
    changelog = "https://github.com/alper-han/CrossMacro/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ alper-han ];
    platforms = lib.platforms.linux;
    mainProgram = "crossmacro";
  };
}
