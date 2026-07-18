{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  buildNpmPackage,
}:

let
  version = "3.0.0";

  pname = "discord-rich-presence-plex";

  src = fetchFromGitHub {
    owner = "phin05";
    repo = "discord-rich-presence-plex";
    rev = "v${version}";
    hash = "sha256-RvsS47059YdxKSo6sy+zglY1YxzyJmZTmo/DIKX1xqU=";
  };

  webAssets = buildNpmPackage {
    inherit version src;
    pname = "${pname}-web";
    npmDepsHash = "sha256-7cp4LeXUAiIHGvLfwsIWpdqjUzemlCKVCsBZxTnPlDk=";

    installPhase = ''
      cp -r dist $out
    '';

    sourceRoot = "${src.name}/web";
  };
in
buildGo126Module {
  inherit version src pname;
  vendorHash = "sha256-B1XHMqyih3eBlRsU6s5HcGv9WY8OcXj2yGwB2jpP9HI=";
  env.GOEXPERIMENT = "jsonv2";

  preBuild = ''
    mkdir -p web/dist
    cp -r ${webAssets}/* web/dist/
  '';

  postInstall = ''
    mv $out/bin/main $out/bin/drpp
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  subPackages = [ "server/main" ];

  meta = {
    description = "Displays your Plex status on Discord using Rich Presence";
    homepage = "https://github.com/phin05/discord-rich-presence-plex";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hogcycle ];
    mainProgram = "discord-rich-presence-plex";
  };
}
