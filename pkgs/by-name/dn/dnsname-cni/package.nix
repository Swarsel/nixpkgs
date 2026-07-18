{
  lib,
  fetchFromGitHub,
  buildGoModule,
  dnsmasq,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "cni-plugin-dnsname";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "dnsname";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-kebN1OLMOrBKBz4aBV0VYm+LmLm6S0mKnVgG2u5I+d4=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = null;
  doCheck = false; # NOTE: requires root privileges

  postInstall = ''
    wrapProgram $out/bin/dnsname --prefix PATH : ${lib.makeBinPath [ dnsmasq ]}
  '';

  subPackages = [ "plugins/meta/dnsname" ];

  meta = {
    description = "DNS name resolution for containers";
    homepage = "https://github.com/containers/dnsname";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mikroskeem ];
    platforms = lib.platforms.linux;
    mainProgram = "dnsname";
  };
})
