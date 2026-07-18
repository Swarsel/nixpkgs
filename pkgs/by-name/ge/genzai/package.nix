{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "genzai";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "umair9747";
    repo = "Genzai";
    tag = finalAttrs.version;
    hash = "sha256-OTkHPzZcPOYZRzEKrJekrgKE/XfGUDL85RjznmrVZb8=";
  };

  vendorHash = null;

  postFixup = ''
    install -vD *.json -t $out/share
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Toolkit to help identify IoT related dashboards and scan them for default passwords and vulnerabilities";
    homepage = "https://github.com/umair9747/Genzai";
    changelog = "https://github.com/umair9747/Genzai/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "genzai";
  };
})
