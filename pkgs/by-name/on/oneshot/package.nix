{
  lib,
  fetchFromGitHub,
  buildGoModule,
  oneshot,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "oneshot";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "forestnode-io";
    repo = "oneshot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eEVjdFHZyk2bSVqrMJIsgZvvLoDOira8zTzX9oDNtHM=";
  };

  vendorHash = "sha256-TktSQMIHYXF9eyY6jyfE31WLXEq7VZU3qnVIMGjMMcA=";
  env.GOWORK = "off";

  installPhase = ''
    runHook preInstall

    install -D -m 555 -T $GOPATH/bin/cmd $out/bin/oneshot

    runHook postInstall
  '';

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
    "-X github.com/forestnode-io/oneshot/v2/pkg/version.Version=${finalAttrs.version}"
    "-X github.com/forestnode-io/oneshot/v2/pkg/version.APIVersion=v1.0.0"
  ];

  modRoot = "v2";
  subPackages = [ "cmd" ];

  passthru.tests.version = testers.testVersion {
    command = "oneshot version";
    package = oneshot;
  };

  meta = {
    description = "First-come first-served single-fire HTTP server";
    homepage = "https://www.oneshot.uno/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ milibopp ];
    mainProgram = "oneshot";
  };
})
