{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

let
  # A list of binaries to put into separate outputs
  bins = [
    "geth"
    "clef"
  ];

in
buildGoModule (finalAttrs: {
  pname = "go-ethereum";
  version = "1.17.3";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "go-ethereum";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BLcpUbE2lkXkpzYWSIVaLNXlFTvSuXw9Vm0iTtrqOKQ=";
  };

  outputs = [ "out" ] ++ bins;
  vendorHash = "sha256-AOdGqr738EgwbZhHHP3ctQYUilgyOc/tIJyaI0H3oeM=";
  doCheck = false;

  # Move binaries to separate outputs and symlink them back to $out
  postInstall = lib.concatStringsSep "\n" (
    map (
      bin:
      "mkdir -p \$${bin}/bin && mv $out/bin/${bin} \$${bin}/bin/ && ln -s \$${bin}/bin/${bin} $out/bin/"
    ) bins
  );

  proxyVendor = true;

  subPackages = [
    "cmd/abidump"
    "cmd/abigen"
    "cmd/blsync"
    "cmd/clef"
    "cmd/devp2p"
    "cmd/era"
    "cmd/ethkey"
    "cmd/evm"
    "cmd/geth"
    "cmd/rlpdump"
    "cmd/utils"
  ];

  # Following upstream: https://github.com/ethereum/go-ethereum/blob/v1.11.6/build/ci.go#L218
  tags = [ "urfave_cli_no_docs" ];
  passthru.tests = { inherit (nixosTests) geth; };

  meta = {
    description = "Official golang implementation of the Ethereum protocol";
    homepage = "https://geth.ethereum.org/";

    license = with lib.licenses; [
      lgpl3Only
      gpl3Only
    ];

    maintainers = with lib.maintainers; [
      asymmetric
      RaghavSood
    ];

    mainProgram = "geth";
  };
})
