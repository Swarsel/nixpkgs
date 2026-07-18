{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  krb5,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  patchelf,
  runtimeShell,
  systemd,
  unzip,
  vulkan-loader,
  wrapGAppsHook3,
}:

let
  pname = "mongodb-compass";
  version = "1.49.10";

  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://downloads.mongodb.com/compass/${
      selectSystem {
        aarch64-darwin = "mongodb-compass-${version}-darwin-arm64.zip";
        x86_64-linux = "mongodb-compass_${version}_amd64.deb";
      }
    }";

    hash = selectSystem {
      aarch64-darwin = "sha256-HGOJPYC4+CgLQQ3BNUTNZUln5oqPkC8ewHft99LCZQ8=";
      x86_64-linux = "sha256-faD8sIbnho5urBWE0btcmD7tXT8eQCNyJYzpIyI+bA4=";
    };
  };

  appName = "MongoDB Compass.app";

  rpath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libnotify
    libsecret
    libuuid
    libxcb
    libxkbcommon
    libgbm
    nspr
    nss
    pango
    stdenv.cc.cc
    systemd
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxkbfile
    libxshmfence
    (lib.getLib stdenv.cc.cc)
  ];
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ unzip ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    dpkg
    wrapGAppsHook3
    patchelf
  ];

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Create directories for the application bundle and the launcher script.
      mkdir -p "$out/Applications/${appName}" "$out/bin"

      # Copy the unzipped app bundle into the Applications folder.
      cp -R . "$out/Applications/${appName}"

      # Create a launcher script that opens the app.
      cat > "$out/bin/${pname}" << EOF
      #!${runtimeShell}
      open -na "$out/Applications/${appName}" --args "\$@"
      EOF
      chmod +x "$out/bin/${pname}"
    ''}

    runHook postInstall
  '';

  buildCommand = lib.optionalString stdenv.hostPlatform.isLinux ''
    IFS=$'\n'

    # The deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    dpkg --fsys-tarfile $src | tar --extract

    mkdir -p $out
    mv usr/* $out

    rm -rf $out/share/lintian

    # The node_modules are bringing in non-linux files/dependencies
    find $out -name "*.app" -exec rm -rf {} \; || true
    find $out -name "*.dll" -delete
    find $out -name "*.exe" -delete

    # Otherwise it looks "suspicious"
    chmod -R g-w $out

    for file in `find $out -type f -perm /0111 -o -name \*.so\*`; do
      echo "Manipulating file: $file"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/lib/mongodb-compass "$file" || true
    done

    wrapGAppsHook $out/bin/mongodb-compass
  '';

  dontFixup = stdenv.hostPlatform.isDarwin;
  dontUnpack = stdenv.hostPlatform.isLinux;
  sourceRoot = lib.optionalString stdenv.hostPlatform.isDarwin appName;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "GUI for MongoDB";
    homepage = "https://github.com/mongodb-js/compass";
    license = lib.licenses.sspl;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      friedow
      iamanaws
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "mongodb-compass";
  };
})
