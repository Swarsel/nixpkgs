{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

let
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "influxdata";
    repo = "influx-cli";
    rev = "v${version}";
    sha256 = "sha256-3DCvWaiGLw9OSs/b9za1jgrPDo2Txw5b5h46ElTMEks=";
  };

in
buildGoModule {
  inherit src;
  pname = "influx-cli";
  version = version;
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-NsOkQwMH/AANUBReXmGR0fFQAtosA9iSla5JXyhrPYE=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd influx \
      --bash <($out/bin/influx completion bash) \
      --zsh  <($out/bin/influx completion zsh)
  '';

  ldflags = [
    "-X main.commit=v${version}"
    "-X main.version=${version}"
  ];

  subPackages = [ "cmd/influx" ];

  meta = {
    description = "CLI for managing resources in InfluxDB v2";
    homepage = "https://influxdata.com/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "influx";
  };
}
