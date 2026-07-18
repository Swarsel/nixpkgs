{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "cni-plugin-flannel";
  version = "1.9.1-flannel1";

  src = fetchFromGitHub {
    owner = "flannel-io";
    repo = "cni-plugin";
    rev = "v${version}";
    sha256 = "sha256-iCSYr7S4oC8a5ijBgqMO/Gn0x/2had372Tx7lkg+X9I=";
  };

  vendorHash = "sha256-PVkhwoGepRhD6VFJxhPA2tZ+zOkhQw0aI2yIWVYQnz8=";
  doCheck = false;

  postInstall = ''
    mv $out/bin/cni-plugin $out/bin/flannel
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/flannel 2>&1 | fgrep -q $version
    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=${version}"
    "-X main.Program=flannel"
  ];

  meta = {
    description = "Network fabric for containers designed to work in conjunction with flannel";
    homepage = "https://github.com/flannel-io/cni-plugin/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ abbe ];
    platforms = lib.platforms.linux;
    mainProgram = "flannel";
  };
}
