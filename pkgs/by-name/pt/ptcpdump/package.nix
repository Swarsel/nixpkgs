{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libpcap,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ptcpdump";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "mozillazg";
    repo = "ptcpdump";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ouH7VFWSCOElbmbSWAkmM4dtNVp545mC/FnoNAFtaEw=";
  };

  buildInputs = [ libpcap ];
  vendorHash = null;

  checkFlags =
    let
      # Skip tests that require network access
      skippedTests = [
        "Test_loadSpecFromBTFHub"
        "Test_loadSpecFromOpenanolis"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X github.com/mozillazg/ptcpdump/internal.Version=v${finalAttrs.version}"
  ];

  tags = [ "dynamic" ];

  meta = {
    description = "Process-aware, eBPF-based tcpdump";
    homepage = "https://github.com/mozillazg/ptcpdump/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ neilmayhew ];
    platforms = lib.platforms.linux;
    mainProgram = "ptcpdump";
  };
})
