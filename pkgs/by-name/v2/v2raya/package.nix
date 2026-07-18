{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchYarnDeps,
  makeWrapper,
  nix-update-script,
  nodejs,
  symlinkJoin,
  v2ray,
  v2ray-domain-list-community,
  v2ray-geoip,
  yarnBuildHook,
  yarnConfigHook,
}:
let
  pname = "v2raya";
  version = "2.2.7.5";

  src = fetchFromGitHub {
    owner = "v2rayA";
    repo = "v2rayA";
    tag = "v${version}";
    hash = "sha256-aa/Eb+fZQ1hwm6H7wb7mr0b4tCu12Mhy14OXNjZUJ0Y=";
    postFetch = "sed -i -e 's/npmmirror/yarnpkg/g' $out/gui/yarn.lock";
  };

  web = stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      nodejs
    ];

    env.OUTPUT_DIR = placeholder "out";

    offlineCache = fetchYarnDeps {
      hash = "sha256-g+hI9n+nfXAcuEpjvDDaHg/DfjtNusOaw3S6kC1QDn4=";
      yarnLock = "${src}/gui/yarn.lock";
    };

    sourceRoot = "${src.name}/gui";
  };

  assetsDir = symlinkJoin {
    name = "assets";

    paths = [
      v2ray-geoip
      v2ray-domain-list-community
    ];
  };

in
buildGoModule {
  inherit pname version src;
  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-uiURsB1V4IB77YKLu5gdaqw9Fuja6fC5adWYDE3OE+Q=";

  preBuild = ''
    cp -a ${web} server/router/web
  '';

  postInstall = ''
    install -Dm 444 ../install/universal/v2raya.desktop -t $out/share/applications
    install -Dm 444 ../install/universal/v2raya.png -t $out/share/icons/hicolor/512x512/apps
    substituteInPlace $out/share/applications/v2raya.desktop \
      --replace-fail 'Icon=/usr/share/icons/hicolor/512x512/apps/v2raya.png' 'Icon=v2raya'

    wrapProgram $out/bin/v2rayA \
      --prefix PATH ":" "${lib.makeBinPath [ v2ray ]}" \
      --prefix XDG_DATA_DIRS ":" ${assetsDir}/share
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/v2rayA/v2rayA/conf.Version=${version}"
  ];

  sourceRoot = "${src.name}/service";
  subPackages = [ "." ];

  passthru = {
    inherit web;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "web"
      ];
    };
  };

  meta = {
    description = "Linux web GUI client of Project V which supports V2Ray, Xray, SS, SSR, Trojan and Pingtunnel";
    homepage = "https://github.com/v2rayA/v2rayA";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ChaosAttractor ];
    platforms = lib.platforms.linux;
    mainProgram = "v2rayA";
  };
}
