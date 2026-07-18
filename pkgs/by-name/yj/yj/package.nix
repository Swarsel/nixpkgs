{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "yj";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "sclevine";
    repo = "yj";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lsn5lxtix5W7po6nzvGcHmifbyhrtHgvaKYT7RPPCOg=";
  };

  vendorHash = "sha256-NeSOoL9wtFzq6ba8ghseB6D+Qq8Z5holQExcAUbtYrs=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Convert YAML <=> TOML <=> JSON <=> HCL";
    homepage = "https://github.com/sclevine/yj";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "yj";
  };
})
