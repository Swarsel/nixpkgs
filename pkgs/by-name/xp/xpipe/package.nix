{
  lib,
  alsa-lib,
  autoPatchelfHook,
  fetchzip,
  fontconfig,
  freetype,
  gtk3,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrender,
  libxtst,
  libxxf86vm,
  makeDesktopItem,
  makeShellWrapper,
  socat,
  stdenvNoCC,
  udev,
  util-linux,
  zlib,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  # Keep this setup to easily add more arch support in the future
  arch =
    {
      x86_64-linux = "x86_64";
    }
    .${system} or throwSystem;

  hash =
    {
      x86_64-linux = "sha256-soypc4tPi9UexNqObZtKWvGgFA/4lPyv5ID3VEbjDDo=";
    }
    .${system} or throwSystem;

  displayname = "XPipe";

in
stdenvNoCC.mkDerivation rec {
  pname = "xpipe";
  version = "23.6";

  src = fetchzip {
    inherit hash;
    url = "https://github.com/xpipe-io/xpipe/releases/download/${version}/xpipe-portable-linux-${arch}.tar.gz";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeShellWrapper
  ];

  buildInputs = [
    fontconfig
    zlib
    udev
    freetype
    gtk3
    alsa-lib
    libx11
    libx11
    libxext
    libxdamage
    libxfixes
    libxcb
    libxcomposite
    libxcursor
    libxi
    libxrender
    libxtst
    libxxf86vm
    util-linux
    socat
  ];

  installPhase = ''
    runHook preInstall

    pkg="${pname}"
    mkdir -p $out/opt/$pkg
    cp -r ./ $out/opt/$pkg

    mkdir -p "$out/bin"
    ln -s "$out/opt/$pkg/bin/xpipe" "$out/bin/$pkg"

    mkdir -p "$out/share/applications"
    cp -r "${desktopItem}/share/applications/" "$out/share/"

    substituteInPlace "$out/share/applications/${displayname}.desktop" --replace "Exec=" "Exec=$out"
    substituteInPlace "$out/share/applications/${displayname}.desktop" --replace "Icon=" "Icon=$out"

    mv "$out/opt/$pkg/bin/xpiped" "$out/opt/$pkg/bin/xpiped_raw"
    mv "$out/opt/$pkg/lib/app/xpiped.cfg" "$out/opt/$pkg/lib/app/xpiped_raw.cfg"
    mv "$out/opt/$pkg/scripts/xpiped_debug.sh" "$out/opt/$pkg/scripts/xpiped_debug_raw.sh"

    makeShellWrapper "$out/opt/$pkg/bin/xpiped_raw" "$out/opt/$pkg/bin/xpiped" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          fontconfig
          gtk3
          udev
          util-linux
          socat
        ]
      }"

    makeShellWrapper "$out/opt/$pkg/scripts/xpiped_debug_raw.sh" "$out/opt/$pkg/scripts/xpiped_debug.sh" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          fontconfig
          gtk3
          udev
          util-linux
          socat
        ]
      }"

    runHook postInstall
  '';

  # Ignore libavformat dependencies as we don't need them
  autoPatchelfIgnoreMissingDeps = true;

  desktopItem = makeDesktopItem {
    categories = [ "Network" ];
    comment = "Your entire server infrastructure at your fingertips";
    desktopName = displayname;
    exec = "/opt/${pname}/bin/xpipe open %U";
    genericName = "Shell connection hub";
    icon = "/opt/${pname}/logo.png";
    name = displayname;
  };

  meta = {
    description = "Cross-platform shell connection hub and remote file manager";
    homepage = "https://github.com/xpipe-io/${pname}";
    changelog = "https://github.com/xpipe-io/${pname}/releases/tag/${version}";

    license = [
      lib.licenses.asl20
      lib.licenses.unfree
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ crschnick ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "xpipe";
    downloadPage = "https://github.com/xpipe-io/${pname}/releases/latest";
  };
}
