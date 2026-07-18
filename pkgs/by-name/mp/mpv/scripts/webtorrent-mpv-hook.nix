{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  cmake,
  gitUpdater,
  libdatachannel,
  nodejs,
  openssl,
  pkg-config,
  plog,
}:

let
  # Modified from pkgs/by-name/ht/httptoolkit-server/package.nix
  nodeDatachannel = buildNpmPackage {
    pname = "node-datachannel";
    version = "0.10.1";

    src = fetchFromGitHub {
      owner = "murat-dogan";
      repo = "node-datachannel";
      tag = "v${nodeDatachannel.version}";
      hash = "sha256-r5tBg645ikIWm+RU7Muw/JYyd7AMpkImD0Xygtm1MUk=";
    };

    nativeBuildInputs = [
      cmake
      pkg-config
    ];

    buildInputs = [
      openssl
      libdatachannel
      plog
    ];

    npmDepsHash = "sha256-1ZJd0Y45B3CT2YPXDYfCuFMBo5uggWRuDH11eCobyyY=";
    env.NIX_CFLAGS_COMPILE = "-I${nodejs}/include/node";

    preBuild = ''
      # don't use static libs and don't use FetchContent
      substituteInPlace CMakeLists.txt \
          --replace-fail 'OPENSSL_USE_STATIC_LIBS TRUE' 'OPENSSL_USE_STATIC_LIBS FALSE' \
          --replace-fail 'if(NOT libdatachannel)' 'if(false)' \
          --replace-fail 'datachannel-static' 'datachannel'
      sed -i '2ifind_package(plog)' CMakeLists.txt

      # don't fetch node headers
      substituteInPlace node_modules/cmake-js/lib/dist.js \
          --replace-fail '!this.downloaded' 'false'
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 build/Release/*.node -t $out/build/Release
      runHook postInstall
    '';

    dontUseCmakeConfigure = true;
    makeCacheWritable = true;
    npmFlags = [ "--ignore-scripts" ];
  };
in

buildNpmPackage rec {
  pname = "webtorrent-mpv-hook";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "mrxdst";
    repo = "webtorrent-mpv-hook";
    rev = "v${version}";
    hash = "sha256-p4Mggt3J8QOok/uj97eCchT7H9HPuDjoyV82MHHkkZM=";
  };

  postPatch = ''
    substituteInPlace src/webtorrent.ts --replace-fail "node_path: 'node'" "node_path: '${lib.getExe nodejs}'"
    # This executable is just for telling non-Nix users how to install
    substituteInPlace package.json --replace-fail '"bin": "build/bin.mjs",' ""
    rm -rf src/bin.ts
  '';

  npmDepsHash = "sha256-tL+MAgiKhwygoAtZaA4nZJ5bq5W5jkYYxOF8Du0rBl8=";

  postConfigure = ''
    # manually place our prebuilt `node-datachannel` binary into its place, since we used '--ignore-scripts'
    ln -s ${nodeDatachannel}/build node_modules/node-datachannel/build
  '';

  postInstall = ''
    mkdir -p $out/share/mpv/scripts/
    ln -s $out/lib/node_modules/webtorrent-mpv-hook/build/webtorrent.js $out/share/mpv/scripts/
  '';

  makeCacheWritable = true;
  npmFlags = [ "--ignore-scripts" ];
  passthru.scriptName = "webtorrent.js";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Adds a hook that allows mpv to stream torrents";
    homepage = "https://github.com/mrxdst/webtorrent-mpv-hook";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.chuangzhu ];
  };
}
