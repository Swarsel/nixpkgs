{
  lib,
  buildGoModule,
  fetchFromGitea,
}:

buildGoModule (finalAttrs: {
  pname = "lenpaste";
  version = "1.3";

  src = fetchFromGitea {
    owner = "root";
    repo = "lenpaste";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-d+FjfEbInlxUllWIoVLwQRdRWjxBLTpNHYn+oYU3fBc=";
    domain = "git.lcomrade.su";
  };

  vendorHash = "sha256-PL0dysBn1+1BpZWFW/EUFJtqkabt+XN00YkAz8Yf2LQ=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/lenpaste
  '';

  ldflags = [
    "-w"
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd" ];

  meta = {
    description = "Web service that allows you to share notes anonymously, an alternative to pastebin.com";
    homepage = "https://git.lcomrade.su/root/lenpaste";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "lenpaste";
  };
})
