{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "snicat";
  version = "0.0.1-unstable-2024-09-05";

  src = fetchFromGitHub {
    owner = "CTFd";
    repo = "snicat";
    rev = "8c8f06e59d5aedb9a97115a4e0eafa75b17a6cdf";
    hash = "sha256-71wVth+VzEnGW8ErWmj6XjhNtVpx/q8lViIA71njwqU=";
  };

  vendorHash = "sha256-27ykI9HK1jFanxwa6QrN6ZS548JbFNSZHaXr4ciCVOE=";

  postInstall = ''
    mv $out/bin/snicat $out/bin/sc
  '';

  ldflags = [
    "-s"
    "-X main.version=v${finalAttrs.version}"
  ];

  proxyVendor = true;

  meta = {
    description = "TLS & SNI aware netcat";
    homepage = "https://github.com/CTFd/snicat";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felixalbrigtsen ];
    mainProgram = "sc";
  };
})
