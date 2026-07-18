{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libtensorflow,
  nixosTests,
  sqlite,
  withTensorflow ? false,
}:
buildGoModule (finalAttrs: {
  pname = "snips-sh";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "robherley";
    repo = "snips.sh";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KPIit7U+630EQ8SeFArCR2qcXVdsjaO1LKZmDO86c0Y=";
  };

  buildInputs = [ sqlite ] ++ (lib.optional withTensorflow libtensorflow);
  vendorHash = "sha256-OjcYz7RdCCWur8y+AhGVlQx3UeW+u6rmB73lDUYBsnM=";
  tags = (lib.optional (!withTensorflow) "noguesser");
  passthru.tests = nixosTests.snips-sh;

  meta = {
    description = "Passwordless, anonymous SSH-powered pastebin with a human-friendly TUI and web UI";
    homepage = "https://snips.sh";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jeremiahs
      matthiasbeyer
    ];

    platforms = lib.platforms.linux;
    mainProgram = "snips.sh";
  };
})
