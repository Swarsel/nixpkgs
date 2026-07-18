{
  lib,
  stdenv,
  fetchFromGitHub,
  diffPlugins,
  libbass,
  libmediainfo,
  libzen,
  pkg-config,
  qmake,
  qtbase,
  qtmultimedia,
  symlinkJoin,
  taglib,
  wrapQtAppsHook,
}:

let
  version = "2019-04-23";
  rev = "ef4524e2239ddbb60f26e05bfba1f4f28cb7b54f";
  sha256 = "0dl2qp686vbs160b3i9qypb7sv37phy2wn21kgzljbk3wnci3yv4";
  buildInputs = [
    qtbase
    qtmultimedia
    taglib
    libmediainfo
    libzen
    libbass
  ];

  plugins = [
    "albumartex"
    "amazon"
    "audiotag"
    "cleanup"
    "freecovers"
    "lyric"
    "preparatory"
    "rename"
  ];

  patchedSrc =
    let
      src = fetchFromGitHub {
        inherit rev sha256;
        owner = "UltraStar-Deluxe";
        repo = "UltraStar-Manager";
      };
    in
    stdenv.mkDerivation {
      inherit src;
      nativeBuildInputs = [ wrapQtAppsHook ];
      dontInstall = true;
      name = "${src.name}-patched";

      patchPhase = ''
        # we don’t want prebuild binaries checked into version control!
        rm -rf lib include

        # fix up main project file
        sed -e 's|-L.*unix.*lbass.*$|-lbass|' \
            -e "/QMAKE_POST_LINK/d" \
            -e "s|../include/bass|${lib.getLib libbass}/include|g" \
            -e "s|../include/taglib|${lib.getLib taglib}/include|g" \
            -e "s|../include/mediainfo|${lib.getLib libmediainfo}/include|g" \
            -i src/UltraStar-Manager.pro

        # if more plugins start depending on ../../../include,
        # it should be abstracted out for all .pro files
        sed -e "s|../../../include/taglib|${lib.getLib taglib}/include/taglib|g" \
            -i src/plugins/audiotag/audiotag.pro

        mkdir $out
        mv * $out
      '';
    };

  patchApplicationPath = file: path: ''
    sed -e "s|QCore.*applicationDirPath()|QString(\"${path}\")|" -i "${file}"
  '';

  buildPlugin =
    name:
    stdenv.mkDerivation {
      src = patchedSrc;

      postPatch = ''
        sed -e "s|DESTDIR = .*$|DESTDIR = $out|" \
            -i src/plugins/${name}/${name}.pro

        # plugins use the application’s binary folder (wtf)
        for f in $(grep -lr "QCoreApplication::applicationDirPath" src/plugins); do
          ${patchApplicationPath "$f" "\$out"}
        done

      '';

      nativeBuildInputs = [ wrapQtAppsHook ];
      buildInputs = [ qmake ] ++ buildInputs;

      preConfigure = ''
        cd src/plugins/${name}
      '';

      name = "ultrastar-manager-${name}-plugin-${version}";
    };

  builtPlugins = symlinkJoin {
    name = "ultrastar-manager-plugins-${version}";
    paths = map buildPlugin plugins;
  };

in
stdenv.mkDerivation {
  inherit version;
  inherit buildInputs;
  pname = "ultrastar-manager";
  src = patchedSrc;

  postPatch = ''
    sed -e "s|DESTDIR =.*$|DESTDIR = $out/bin|" \
        -i src/UltraStar-Manager.pro
    # patch plugin manager to point to the collected plugin folder
    ${patchApplicationPath "src/plugins/QUPluginManager.cpp" builtPlugins}
  '';

  nativeBuildInputs = [
    pkg-config
    wrapQtAppsHook
  ];

  buildPhase = ''
    find -path './src/plugins/*' -prune -type d -print0 \
      | xargs -0 -i'{}' basename '{}' \
      | sed -e '/shared/d' \
      > found_plugins
    ${diffPlugins plugins "found_plugins"}

    cd src && qmake && make
  '';

  # is not installPhase so that qt post hooks can run
  preInstall = ''
    make install
  '';

  meta = {
    description = "Ultrastar karaoke song manager";
    homepage = "https://github.com/UltraStar-Deluxe/UltraStar-Manager";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "UltraStar-Manager";
  };
}
