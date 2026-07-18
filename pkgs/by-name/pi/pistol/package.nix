{
  lib,
  fetchFromGitHub,
  asciidoctor,
  buildGoModule,
  file,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "pistol";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "doronbehar";
    repo = "pistol";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-cL9hHehajqMIpdD10KYIbNkBt2fiRQkx81m9H3Yd1UY=";
  };

  nativeBuildInputs = [
    installShellFiles
    asciidoctor
  ];

  buildInputs = [
    file
  ];

  vendorHash = "sha256-+moQ3qZnWmmGpOXUxyBS3hIETK/ZtRwmvD2tXFf0A3o=";
  doCheck = false;

  postInstall = ''
    asciidoctor -b manpage -d manpage README.adoc
    installManPage pistol.1
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/pistol" ];

  meta = {
    description = "General purpose file previewer designed for Ranger, Lf to make scope.sh redundant";
    homepage = "https://github.com/doronbehar/pistol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "pistol";
  };
})
