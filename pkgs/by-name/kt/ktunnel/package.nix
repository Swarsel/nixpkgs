{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "1.6.1";
in
buildGoModule {
  inherit version;
  pname = "ktunnel";

  src = fetchFromGitHub {
    owner = "omrikiei";
    repo = "ktunnel";
    rev = "v${version}";
    sha256 = "sha256-rcUCIUIyBCSuMly7y0GUNQCdJUgsj7Oi6Hpz23uXoJw=";
  };

  vendorHash = "sha256-Q8t/NWGeUB1IpxdsxvyvbYh/adtcA4p+7bcCy9YFjsw=";
  # # TODO investigate why some tests are failing
  doCheck = false;
  preCheck = "export HOME=$(mktemp -d)";

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/ktunnel" --version
    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Cli that exposes your local resources to kubernetes";
    homepage = "https://github.com/omrikiei/ktunnel";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "ktunnel";
  };
}
