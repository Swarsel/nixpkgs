{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go-protobuf,
  iptables,
  libnetfilter_queue,
  libnfnetlink,
  makeWrapper,
  nix-update-script,
  nixosTests,
  opensnitch,
  opensnitch-ui,
  pkg-config,
  protobuf,
  protoc-gen-go-grpc,
  testers,
}:
let
  # Override protoc-gen-go-grpc to use the compatible version
  # Should be droppable on opensnitch 1.7.0
  protoc-gen-go-grpc' = protoc-gen-go-grpc.overrideAttrs (oldAttrs: rec {
    version = "1.3.0";

    src = fetchFromGitHub {
      owner = "grpc";
      repo = "grpc-go";
      rev = "cmd/protoc-gen-go-grpc/v${version}";
      hash = "sha256-Zy0k5X/KFzCao9xAGt5DNb0MMGEyqmEsDj+uvXI4xH4=";
    };

    vendorHash = "sha256-y+/hjYUTFZuq55YAZ5M4T1cwIR+XFQBmWVE+Cg1Y7PI=";
  });
in
buildGoModule (finalAttrs: {
  pname = "opensnitch";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "evilsocket";
    repo = "opensnitch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bz5h2DEC61vpkeWZxFlogh6NvTubJcnHuwgTNSzZd68=";
  };

  postPatch = ''
    # Allow configuring Version at build time
    substituteInPlace daemon/core/version.go --replace-fail "const " "var "
  '';

  nativeBuildInputs = [
    pkg-config
    protobuf
    go-protobuf
    makeWrapper
    protoc-gen-go-grpc'
  ];

  buildInputs = [
    libnetfilter_queue
    libnfnetlink
  ];

  vendorHash = "sha256-6/N/E+uk6RVmSLy6fSWjHj+J5mPFXtHZwWThhFJnfYY=";

  preBuild = ''
    make -C ../proto ../daemon/ui/protocol/ui.pb.go
  '';

  postBuild = ''
    mv $GOPATH/bin/daemon $GOPATH/bin/opensnitchd
    mkdir -p $out/etc/opensnitchd $out/lib/systemd/system
    cp -r data/{rules,*.json} $out/etc/opensnitchd/
    substituteInPlace $out/etc/opensnitchd/default-config.json \
      --replace-fail "/var/log/opensnitchd.log" "/dev/stdout"
    # Fixup hardcoded paths
    substitute data/init/opensnitchd.service $out/lib/systemd/system/opensnitchd.service \
      --replace-fail "/usr/local/bin/opensnitchd" "$out/bin/opensnitchd"
  '';

  postInstall = ''
    wrapProgram $out/bin/opensnitchd \
      --prefix PATH : ${lib.makeBinPath [ iptables ]}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/evilsocket/opensnitch/daemon/core.Version=${finalAttrs.version}"
  ];

  modRoot = "daemon";

  passthru = {
    tests = {
      inherit (nixosTests) opensnitch;
      inherit opensnitch-ui;

      version = testers.testVersion {
        command = "opensnitchd -version";
        package = opensnitch;
      };
    };

    updater = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v([0-9.]+)$"
      ];
    };
  };

  meta = {
    description = "Application firewall";
    homepage = "https://github.com/evilsocket/opensnitch/wiki";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      onny
      grimmauld
    ];

    platforms = lib.platforms.linux;
    mainProgram = "opensnitchd";
  };
})
