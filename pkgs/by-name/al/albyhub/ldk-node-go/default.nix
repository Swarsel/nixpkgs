{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ldkNode,
}:

buildGoModule {
  pname = "ldk-node-go";
  version = "0-unstable-2026-06-08";

  src = fetchFromGitHub {
    owner = "getAlby";
    repo = "ldk-node-go";
    rev = "5ba22268f000c78baa5cf57329eb0b1c07bd91d7";
    hash = "sha256-+fuCvc2SuxBLXiacfc+0oNzAsBgFjUJgZ0+5B4Sy4vs=";
  };

  buildInputs = [
    ldkNode
  ];

  propagatedBuildInputs = [ ldkNode ];
  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Experimental Go bindings for LDK-node";
    homepage = "https://github.com/getAlby/ldk-node-go";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bleetube ];
    platforms = lib.platforms.linux;
  };
}
