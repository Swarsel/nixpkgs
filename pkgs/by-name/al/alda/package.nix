{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gradle,
  jre,
  makeWrapper,
  symlinkJoin,
}:
let
  pname = "alda";
  version = "2.3.2";
  src = fetchFromGitHub {
    owner = "alda-lang";
    repo = "alda";
    tag = "release-${version}";
    hash = "sha256-qOEYBWU9xL62MyLSsJ0wtNea2eRhd/3ZT27j3gmNzQI=";
  };
  license = lib.licenses.epl20;

  alda_client = buildGoModule {
    inherit version src;
    pname = "alda-client";
    vendorHash = "sha256-h09w6ZLirLNxYv/ibeN5pCnXSvT+1FGiXiYNReZBMXI=";
    env.CGO_ENABLED = 0;

    preBuild = ''
      go generate main.go
    '';

    postInstall = ''
      mv $out/bin/client $out/bin/alda
    '';

    ldflags = [
      "-w"
      "-extldflags '-static'"
    ];

    sourceRoot = "${src.name}/client";
    subPackages = [ "." ];
    tags = [ "netgo" ];

    meta = {
      inherit license;
      homepage = "https://github.com/alda-lang/alda/tree/master/client";
      maintainers = [ lib.maintainers.ericdallo ];
      platforms = lib.platforms.unix;
      broken = !stdenv.buildPlatform.canExecute stdenv.hostPlatform;
    };
  };
  alda_player = stdenv.mkDerivation {
    inherit version src;
    pname = "alda-player";

    nativeBuildInputs = [
      gradle
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share}
      cp build/libs/alda-player-fat.jar $out/share

      makeWrapper ${lib.getExe jre} $out/bin/alda-player \
        --add-flags "-jar $out/share/alda-player-fat.jar"

      runHook postInstall
    '';

    __darwinAllowLocalNetworking = true;
    gradleBuildTask = "fatJar";

    mitmCache = gradle.fetchDeps {
      inherit pname;
      data = ./deps.json;
    };

    sourceRoot = "${src.name}/player";

    meta = {
      inherit license;
      homepage = "https://github.com/alda-lang/alda/tree/master/player";
      maintainers = [ lib.maintainers.ericdallo ];
      platforms = lib.platforms.unix;
    };
  };
in
symlinkJoin {
  inherit pname version;

  paths = [
    alda_client
    alda_player
  ];

  meta = {
    inherit license;
    description = "Music programming language for musicians";
    homepage = "https://alda.io";

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = [ lib.maintainers.ericdallo ];
    platforms = lib.platforms.unix;
  };
}
