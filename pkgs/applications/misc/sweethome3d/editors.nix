{
  lib,
  stdenv,
  ant,
  fetchzip,
  gsettings-desktop-schemas,
  gtk3,
  jdk,
  makeDesktopItem,
  makeWrapper,
  stripJavaArchivesHook,
  sweethome3dApp,
  unzip,
}:

let

  sweetExec = m: "sweethome3d-" + lib.removeSuffix "libraryeditor" (lib.toLower m) + "-editor";

  mkEditorProject =
    {
      description,
      desktopName,
      license,
      module,
      pname,
      src,
      version,
    }:

    stdenv.mkDerivation rec {
      inherit
        pname
        module
        version
        src
        description
        ;

      postPatch = ''
        sed -i -e 's,../SweetHome3D,${sweethome3dApp.src},g' build.xml
        sed -i -e 's,lib/macosx/java3d-1.6/jogl-all.jar,lib/java3d-1.6/jogl-all.jar,g' build.xml
      '';

      nativeBuildInputs = [
        makeWrapper
        stripJavaArchivesHook
      ];

      buildInputs = [
        ant
        jdk
        gtk3
        gsettings-desktop-schemas
      ];

      # upstream targets Java 7 by default
      env.ANT_ARGS = "-DappletClassSource=8 -DappletClassTarget=8 -DclassSource=8 -DclassTarget=8";

      buildPhase = ''
        runHook preBuild

        ant -lib ${sweethome3dApp.src}/libtest -lib ${sweethome3dApp.src}/lib -lib ${jdk}/lib

        runHook postBuild
      '';

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/share/{java,applications}
        cp ${module}-${version}.jar $out/share/java/.
        cp "${editorItem}/share/applications/"* $out/share/applications
        makeWrapper ${jdk}/bin/java $out/bin/$exec \
          --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:${gtk3.out}/share:${gsettings-desktop-schemas}/share:$out/share:$GSETTINGS_SCHEMAS_PATH" \
          --add-flags "-jar $out/share/java/${module}-${version}.jar -d${toString stdenv.hostPlatform.parsed.cpu.bits}"
      '';

      application = sweethome3dApp;
      dontStrip = true;

      editorItem = makeDesktopItem {
        inherit exec desktopName;

        categories = [
          "Graphics"
          "2DGraphics"
          "3DGraphics"
        ];

        comment = description;
        genericName = "Computer Aided (Interior) Design";
        name = pname;
      };

      exec = sweetExec module;

      meta = {
        inherit description;
        inherit license;
        homepage = "http://www.sweethome3d.com/index.jsp";
        maintainers = [ lib.maintainers.edwtjo ];
        platforms = lib.platforms.linux;
        mainProgram = exec;
      };

    };

  d2u = lib.replaceStrings [ "." ] [ "_" ];

in
{

  furniture-editor = mkEditorProject rec {
    pname = module;
    version = "1.28";

    src = fetchzip {
      url = "mirror://sourceforge/sweethome3d/${module}-${version}-src.zip";
      hash = "sha256-pqsSxQPzsyx4PS98fgU6UFhPWhpQoepGm0uJtkvV46c=";
    };

    description = "Quickly create SH3F files and edit the properties of the 3D models it contain";
    desktopName = "Sweet Home 3D - Furniture Library Editor";
    license = lib.licenses.gpl2Plus;
    module = "FurnitureLibraryEditor";
  };

  textures-editor = mkEditorProject rec {
    pname = module;
    version = "1.7";

    src = fetchzip {
      url = "mirror://sourceforge/sweethome3d/${module}-${version}-src.zip";
      hash = "sha256-v8hMEUujTgWvFnBTF8Dnd1iWgoIXBzGMUxBgmjdxx+g=";
    };

    description = "Easily create SH3T files and edit the properties of the texture images it contain";
    desktopName = "Sweet Home 3D - Textures Library Editor";
    license = lib.licenses.gpl2Plus;
    module = "TexturesLibraryEditor";
  };

}
