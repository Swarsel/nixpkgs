{
  stdenv,
  autoPatchelfHook,
  cups,
  dbus,
  fontconfig,
  gccForLibs,
  libinput,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxtst,
  nss,
  qtbase,
  qtmultimedia,
  qtsvg,
  qttools,
  qtwebengine,
  qtwebview,
}:

{
  meta,
  pname,
  src,
  version,
}:
let
  unwrapped = stdenv.mkDerivation {
    inherit version src meta;
    pname = "${pname}-unwrapped";

    patches = [
      ./libs.patch # Fixes issues with bundled libraries that we've stripped out
    ];

    postPatch = ''
      rm -r lib/plugins lib/libQt6* lib/libssl* lib/libicu* lib/libcrypto*
    '';

    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [
      cups
      dbus
      fontconfig
      gccForLibs
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxi
      libxrandr
      libxrender
      libxtst
      libinput
      libxcb
      libxkbcommon
      nss
      qtbase
      qtmultimedia
      qtsvg
      qttools
      qtwebengine
      qtwebview
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
    ];

    installPhase = ''
      mkdir -p $out
      cp -r bin lib $out
      addAutoPatchelfSearchPath $out/lib
      ln -s "${qtbase}/${qtbase.qtPluginPrefix}" $out/lib/plugins
    '';

    preFixup = ''
      patchelf --clear-symbol-version close $out/bin/p4{v,admin}.bin
    '';

    dontBuild = true;
    # Don't wrap the Qt apps; upstream has its own wrapper scripts.
    dontWrapQtApps = true;
  };
in
stdenv.mkDerivation {
  inherit pname version;
  inherit (unwrapped) meta passthru;

  # Build a "clean" version of the package so that we don't add extra ".bin" or
  # configuration files to users' PATHs. We can't easily put the unwrapped
  # package files in libexec (where they belong, probably) because the upstream
  # wrapper scripts have the bin directory hardcoded.
  buildCommand = ''
    mkdir -p $out/bin
    for f in p4admin p4merge p4v p4vc; do
      ln -s ${unwrapped}/bin/$f $out/bin
    done
  '';

  preferLocalBuild = true;
}
