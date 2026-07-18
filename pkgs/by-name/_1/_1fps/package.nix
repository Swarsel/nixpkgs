{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libx11,
  libxi,
  libxtst,
}:
buildGoModule (finalAttrs: {
  pname = "1fps";
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "1fpsvideo";
    repo = "1fps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8dtcW/niwmhVXB2kZdR/RjNg2ArSClL1w4nGI5rP3+Y=";
  };

  buildInputs = [
    libx11
    libxtst
    libxi
  ];

  vendorHash = "sha256-29x5Lh++NBAsg2O2Vr6pf9iRuVOvow2R5Iqz6twZGXA=";
  proxyVendor = true;

  meta = {
    description = "Encrypted Screen Sharing";
    homepage = "https://1fps.video";
    license = lib.licenses.fsl11Asl20;
    maintainers = with lib.maintainers; [ renesat ];
    mainProgram = "1fps";
  };
})
