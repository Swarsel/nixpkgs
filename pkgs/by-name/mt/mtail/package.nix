{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gotools,
}:

buildGoModule (finalAttrs: {
  pname = "mtail";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "jaqx0r";
    repo = "mtail";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KX47oD7qLBpwItUVltysiekjy4wtpK13SVdvjSx9jmU=";
  };

  nativeBuildInputs = [
    gotools # goyacc
  ];

  vendorHash = "sha256-9XEg7Io3yi/6PKgc0oKmTWNYACOLf8FfKM/c15jXOUQ=";

  preBuild = ''
    GOOS= GOARCH= go generate ./...
  '';

  # fails on darwin with: write unixgram -> <tmpdir>/rsyncd.log: write: message too long
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkFlags = [
    # can only be executed under bazel
    "-skip=TestExecMtail"
  ];

  ldflags = [
    "-X=main.Branch=main"
    "-X=main.Version=${finalAttrs.version}"
    "-X=main.Revision=${finalAttrs.src.rev}"
  ];

  proxyVendor = true;

  meta = {
    description = "Tool for extracting metrics from application logs";
    homepage = "https://github.com/jaqx0r/mtail";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "mtail";
  };
})
