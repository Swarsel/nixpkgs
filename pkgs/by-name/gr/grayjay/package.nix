{
  lib,
  fetchFromGitLab,
  _experimental-update-script-combinators,
  alsa-lib,
  atk,
  autoPatchelfHook,
  buildDotnetModule,
  buildNpmPackage,
  cairo,
  copyDesktopItems,
  cups,
  dbus,
  dotnetCorePackages,
  expat,
  glib,
  gtk3,
  icu,
  krb5,
  libGL,
  libdrm,
  libgbm,
  libgcc,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libz,
  makeDesktopItem,
  nix-update-script,
  nspr,
  nss,
  openssl,
  pango,
  udev,
  wrapGAppsHook3,
}:
let
  version = "17";
  src = fetchFromGitLab {
    owner = "videostreaming";
    repo = "Grayjay.Desktop";
    tag = version;
    hash = "sha256-/oeoLXKewjYkCO7naZNOzauWm1OYDKnsxXY9EkI7fTM=";
    fetchSubmodules = true;
    domain = "gitlab.futo.org";
    fetchLFS = true;
  };
  frontend = buildNpmPackage {
    inherit version src;
    pname = "grayjay-frontend";
    npmDepsHash = "sha256-3yJIPkuEvkFL9Wb4y/r0yEULQbXx/wHqicFBLzOPj68=";

    installPhase = ''
      runHook preInstall
      cp -r dist/ $out
      runHook postInstall
    '';

    npmBuildScript = "build";
    sourceRoot = "source/Grayjay.Desktop.Web";
  };
in
buildDotnetModule (finalAttrs: {
  inherit version src frontend;
  pname = "grayjay";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    openssl
    libgbm
    libgcc
    libx11
    gtk3
    glib
    alsa-lib
    nspr
    nss
    icu
    krb5
  ];

  preBuild = ''
    rm -r Grayjay.ClientServer/wwwroot/web
    cp -r ${frontend} Grayjay.ClientServer/wwwroot/web
  '';

  postInstall = ''
    chmod +x $out/lib/grayjay/cef/dotcefnative
    chmod +x $out/lib/grayjay/ffmpeg
    rm $out/lib/grayjay/Portable
    ln -s /tmp/grayjay-launch $out/lib/grayjay/launch
    ln -s /tmp/grayjay-cef-launch $out/lib/grayjay/cef/launch
    mkdir -p $out/share/icons/hicolor/scalable/apps
    ln -s $out/lib/grayjay/grayjay.png $out/share/icons/hicolor/scalable/apps/grayjay.png
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      comment = "Cross platform media application for streaming and downloading media";
      desktopName = "Grayjay Desktop";
      exec = "Grayjay";
      icon = "grayjay";
      name = "Grayjay";
    })
  ];

  dontWrapGApps = true;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  dotnet-sdk = dotnetCorePackages.sdk_9_0 // {
    inherit
      (dotnetCorePackages.combinePackages [
        dotnetCorePackages.sdk_9_0
        dotnetCorePackages.sdk_8_0
      ])
      packages
      targetPackages
      ;
  };

  executables = [ "Grayjay" ];

  makeWrapperArgs = [
    "--chdir"
    "${placeholder "out"}/lib/grayjay"
  ];

  nugetDeps = ./deps.json;

  projectFile = [
    "Grayjay.ClientServer/Grayjay.ClientServer.csproj"
    "Grayjay.Engine/Grayjay.Engine/Grayjay.Engine.csproj"
    "Grayjay.Desktop.CEF/Grayjay.Desktop.CEF.csproj"
    "FUTO.MDNS/FUTO.MDNS/FUTO.MDNS.csproj"
    "JustCef/DotCef.csproj"
  ];

  runtimeDeps = [
    libz

    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb

    dbus
    atk
    cups
    libdrm
    expat
    libxkbcommon
    pango
    cairo
    udev
    libGL
    libsecret
  ];

  testProjectFile = [
    "Grayjay.Engine/Grayjay.Engine.Tests/Grayjay.Engine.Tests.csproj"
  ];

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "--subpackage"
        "frontend"
        "--url"
        "https://gitlab.futo.org/api/v4/projects/videostreaming%2FGrayjay%2EDesktop/repository/archive.tar.gz?sha=refs%2Ftags%2F10"
      ];
    })
    finalAttrs.passthru.fetch-deps
  ];

  meta = {
    description = "Cross-platform application to stream and download content from various sources";

    longDescription = ''
      Grayjay is a cross-platform application that enables users to
      stream and download multimedia content from various online sources,
      most prominently YouTube.
      It also offers an extensible plugin API to create and import new
      integrations.
    '';

    homepage = "https://grayjay.app/desktop/";
    license = lib.licenses.sfl;

    maintainers = with lib.maintainers; [
      kruziikrel13
      samfundev
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "Grayjay";
  };
})
