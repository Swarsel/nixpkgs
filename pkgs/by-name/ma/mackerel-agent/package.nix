{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  iproute2,
  makeWrapper,
  net-tools,
}:

buildGoModule (finalAttrs: {
  pname = "mackerel-agent";
  version = "0.85.2";

  src = fetchFromGitHub {
    owner = "mackerelio";
    repo = "mackerel-agent";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-3A3x32JytJGXebgZeJcToHXNqRB+rbyziT5Zwgc9rEM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ iproute2 ];
  vendorHash = "sha256-Ubk/ms/3FwH1ZqZ5uTy0MubXhrKBoeaC85Y1KKH5cIw=";
  doCheck = true;
  nativeCheckInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ net-tools ];

  postInstall = ''
    wrapProgram $out/bin/mackerel-agent \
      --prefix PATH : "${lib.makeBinPath finalAttrs.buildInputs}"
  '';

  ldflags = [
    "-X=main.version=${finalAttrs.version}"
    "-X=main.gitcommit=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "System monitoring service for mackerel.io";
    homepage = "https://github.com/mackerelio/mackerel-agent";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ midchildan ];
    mainProgram = "mackerel-agent";
  };
})
