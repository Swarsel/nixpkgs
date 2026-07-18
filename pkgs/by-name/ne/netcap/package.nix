{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  libflowmanager,
  libpcap,
  libprotoident,
  libtrace,
  ndpi,
  nix-update-script,
  pkg-config,
  protobuf,
  protoc-gen-go,
  versionCheckHook,
  yara-x,
  withDpi ? true,
}:
let
  ndpi_4_14 = callPackage ./ndpi_4_14.nix { };
in
buildGoModule (finalAttrs: {
  pname = "netcap";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "dreadl0ck";
    repo = "netcap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hk0aPU+pQ+A90GvlFhCRpj4hRiFOcpcP64xznh50Kts=";
  };

  postPatch = ''
    rm go.work go.work.sum
  '';

  nativeBuildInputs = [
    pkg-config
    protobuf
    protoc-gen-go
  ];

  buildInputs = [
    libpcap
    yara-x
  ]
  ++ lib.optionals withDpi [
    ndpi_4_14
    libprotoident
    libflowmanager
    libtrace
  ];

  vendorHash = "sha256-DLjSeSXwA4zPVg3ISPqEHTihIp9uVu7dXv9bTSepsaI=";

  env = lib.optionalAttrs withDpi {
    CGO_CFLAGS = toString [
      "-I${ndpi_4_14}/include"
      "-I${libprotoident}/include"
    ];

    CGO_LDFLAGS = toString [
      "-L${ndpi_4_14}/lib"
      "-lndpi"
      "-L${libprotoident}/lib"
      "-lprotoident"
    ];
  };

  preBuild = ''
    # satisfiy go:embed
    mkdir -p cmd/capture/webui/frontend/dist
    touch cmd/capture/webui/frontend/dist/index.html

    # generate protobuf types
    # we need to patch the proto file to have a valid go_package
    substituteInPlace netcap.proto --replace-fail 'option go_package = "types";' 'option go_package = "github.com/dreadl0ck/netcap/types";'
    protoc --go_out=. --go_opt=paths=source_relative netcap.proto
    mv netcap.pb.go types/

    # Patch types to replace calling String() (panics) with string literal
    find types -name "*.go" -exec sed -i 's/Type_NC_\([A-Za-z0-9_]*\).String()/"NC_\1"/g' {} +
  '';

  checkFlags =
    let
      skippedTests = [
        # couldn't open packet socket: operation not permitted
        "TestCaptureLive"
        # requires local test data
        "TestCapturePCAP"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/net
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd" ];

  tags = lib.optionals (!withDpi) [
    "nodpi"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/net";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Framework for secure and scalable network traffic analysis";
    homepage = "https://netcap.io";
    changelog = "https://github.com/dreadl0ck/netcap/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ felbinger ];
    mainProgram = "net";
    downloadPage = "https://github.com/dreadl0ck/netcap";
  };
})
