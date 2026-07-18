{
  lib,
  stdenv,
  buildGoModule,
  tailscale,
}:

buildGoModule {
  inherit (tailscale) version src vendorHash;
  pname = "tailscale-nginx-auth";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mv $out/bin/nginx-auth $out/bin/tailscale.nginx-auth
    sed -i -e "s#/usr/sbin#$out/bin#" ./cmd/nginx-auth/tailscale.nginx-auth.service
    install -D -m0444 -t $out/lib/systemd/system ./cmd/nginx-auth/tailscale.nginx-auth.service
    install -D -m0444 -t $out/lib/systemd/system ./cmd/nginx-auth/tailscale.nginx-auth.socket
  '';

  ldflags = [
    "-w"
    "-s"
    "-X tailscale.com/version.longStamp=${tailscale.version}"
    "-X tailscale.com/version.shortStamp=${tailscale.version}"
  ];

  subPackages = [ "cmd/nginx-auth" ];

  meta = {
    description = "Tool that allows users to use Tailscale Whois authentication with NGINX as a reverse proxy";
    homepage = "https://tailscale.com";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "tailscale.nginx-auth";
  };
}
