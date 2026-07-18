{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  glib,
  gtk2,
  icoutils,
  makeDesktopItem,
  makeWrapper,
  mono,
  replaceVars,
  unixtools,
  unzip,
  writeText,
  xdotool,
  xprop,
  xsel,
  plugins ? [ ],
}:
let
  # KeePass looks for plugins in under directory in which KeePass.exe is
  # located. It follows symlinks where looking for that directory, so
  # buildEnv is not enough to bring KeePass and plugins together.
  #
  # This derivation patches KeePass to search for plugins in specified
  # plugin derivations in the Nix store and nowhere else.
  pluginLoadPathsPatch =
    let
      inherit (builtins) toString;
      inherit (lib.strings)
        readFile
        concatStrings
        replaceStrings
        unsafeDiscardStringContext
        ;
      inherit (lib.lists) map length;
      inherit (lib) add;

      outputLc = toString (add 7 (length plugins));
      patchTemplate = readFile ./keepass-plugins.patch;
      loadTemplate = readFile ./keepass-plugins-load.patch;
      loads = concatStrings (
        map (
          p: replaceStrings [ "$PATH$" ] [ (unsafeDiscardStringContext (toString p)) ] loadTemplate
        ) plugins
      );
    in
    writeText "load-paths.patch" (
      replaceStrings [ "$OUTPUT_LC$" "$DO_LOADS$" ] [ outputLc loads ] patchTemplate
    );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "keepass";
  version = "2.60";

  src = fetchurl {
    url = "mirror://sourceforge/keepass/KeePass-${finalAttrs.version}-Source.zip";
    hash = "sha256-AraAdneAkLTS1wZ7pWC0Mm51m50s2hCy6wN74nlUtxo=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      gsettings = "${glib}/bin/gsettings";
      uname = "${coreutils}/bin/uname";
      whereis = "${unixtools.whereis}/bin/whereis";
      xdotool = "${xdotool}/bin/xdotool";
      xprop = "${xprop}/bin/xprop";
      xsel = "${xsel}/bin/xsel";
    })
  ];

  postPatch = ''
    sed -i 's/\r*$//' KeePass/Forms/MainForm.cs
    patch -p1 <${pluginLoadPathsPatch}
  '';

  nativeBuildInputs = [
    unzip
    mono
    makeWrapper
  ];

  buildInputs = [ icoutils ];

  buildPhase = ''
    runHook preBuild

    xbuild KeePass.sln /p:Configuration=Release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    target="$out/lib/dotnet/keepass"
    mkdir -p "$target"

    cp -rv $outputFiles "$target"

    makeWrapper \
      "${mono}/bin/mono" \
      "$out/bin/keepass" \
      --add-flags "$target/KeePass.exe" \
      --prefix PATH : "$binPaths" \
      --prefix LD_LIBRARY_PATH : "$dynlibPath"

    # setup desktop item with icon
    mkdir -p "$out/share/applications"
    cp $desktopItem/share/applications/* $out/share/applications

    ${./extractWinRscIconsToStdFreeDesktopDir.sh} \
      "./Translation/TrlUtil/Resources/KeePass.ico" \
      '[^\.]+_[0-9]+_([0-9]+x[0-9]+)x[0-9]+\.png' \
      '\1' \
      '([^\.]+).+' \
      'keepass' \
      "$out" \
      "./tmp"
    runHook postInstall
  '';

  # plgx plugin like keefox requires mono to compile at runtime
  # after loading. It is brought into plugins bin/ directory using
  # buildEnv in the plugin derivation. Wrapper below makes sure it
  # is found and does not pollute output path.
  binPaths = lib.concatStringsSep ":" (map (x: x + "/bin") plugins);

  configurePhase = ''
    runHook preConfigure

    rm -rvf Build/*
    find . -name "*.sln" -print -exec sed -i 's/Format Version 10.00/Format Version 11.00/g' {} \;
    find . -name "*.csproj" -print -exec sed -i '
      s#ToolsVersion="3.5"#ToolsVersion="4.0"#g
      s#<TargetFrameworkVersion>.*</TargetFrameworkVersion>##g
      s#<PropertyGroup>#<PropertyGroup><TargetFrameworkVersion>v4.5</TargetFrameworkVersion>#g
      s#<SignAssembly>.*$#<SignAssembly>false</SignAssembly>#g
      s#<PostBuildEvent>.*sgen.exe.*$##
    ' {} \;

    runHook postConfigure
  '';

  desktopItem = makeDesktopItem {
    categories = [ "Utility" ];
    comment = "Password manager";
    desktopName = "Keepass";
    exec = "keepass";
    genericName = "Password manager";
    icon = "keepass";
    mimeTypes = [ "application/x-keepass2" ];
    name = "keepass";
  };

  dynlibPath = lib.makeLibraryPath [ gtk2 ];

  outputFiles = [
    "Build/KeePass/Release/*"
    "Build/KeePassLib/Release/*"
    "Ext/KeePass.config.xml" # contains <PreferUserConfiguration>true</PreferUserConfiguration>
  ];

  sourceRoot = ".";

  meta = {
    description = "GUI password manager with strong cryptography";
    homepage = "http://www.keepass.info/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      obadz
    ];

    platforms = with lib.platforms; all;
    mainProgram = "keepass";
  };
})
