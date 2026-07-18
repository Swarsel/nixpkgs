{
  _7zz,
  meta,
  pname,
  src,
  stdenvNoCC,
  version,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  # dmg is APFS formatted
  nativeBuildInputs = [ _7zz ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -a WeChat.app $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";

  # ERROR: Dangerous link path was ignored : WeChat.app/Contents/MacOS/WeChatAppEx.app/Contents/Frameworks/WeChatAppEx Framework.framework/Versions/C/Libraries/xfile/libxfile_skia.dylib : ../xeditor/libxeditor_app.dylib
  unpackCmd = ''
    7zz x -snld "$curSrc"
  '';
}
