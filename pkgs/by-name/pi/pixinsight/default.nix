{
  lib,
  stdenv,
  bubblewrap,
  cudaSupport,
  fakeroot,
  requireFile,
  unixtools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixinsight";
  version = "1.9.4-20260621";

  src = requireFile {
    url = "http://pixinsight.com";
    hash = "sha256-ITJq6q7rLBYe1+6jk2ZtpOSu5M5Z5bRzFPu06PPd7UI=";
    name = "PI-linux-x64-${finalAttrs.version}-c.tar.xz";
  };

  # Patch installer binary with correct interpreter and rpath
  postPatch = ''
    patchelf ./installer \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${lib.getLib stdenv.cc.cc}/lib
  '';

  nativeBuildInputs = [
    bubblewrap
    fakeroot
    unixtools.script
  ];

  installPhase = ''
    runHook preInstall

    # Prepare output directories
    mkdir -p $out/opt
    mkdir -p $out/share/{applications,mime/packages}
    for i in 16 24 32 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/"$i"x"$i"/apps
    done
    mkdir -p $out/share/icons/hicolor/scalable/apps

    # Install using proper bind-mounts
    bwrap \
      --bind /build /build \
      --bind $out/opt /opt \
      --bind /nix /nix \
      --dev /dev \
      fakeroot script -ec "./installer \
        --yes \
        --install-desktop-dir=$out/share/applications \
        --install-mime-dir=$out/share/mime \
        --install-icons-dir=$out/share/icons/hicolor \
        --no-bin-launcher"
  ''
  + lib.optionalString cudaSupport ''
    # Remove bundled libtensorflow-cpu files
    rm -f $out/opt/PixInsight/bin/lib/libtensorflow*
  ''
  + ''
    runHook postInstall
  '';

  postFixup = ''
    # Patch desktop entry for downstream compatibility
    substituteInPlace $out/share/applications/PixInsight.desktop \
      --replace-fail "Exec=/opt/PixInsight/bin/PixInsight.sh" "Exec=pixinsight"
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  meta = {
    description = "Scientific image processing program for astrophotography";
    homepage = "https://pixinsight.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      sheepforce
      kulczwoj
    ];

    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [ ];
  };
})
