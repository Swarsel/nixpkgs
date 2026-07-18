{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "wappalyzergo";
  version = "0.2.89";

  src = fetchFromGitHub {
    owner = "projectdiscovery";
    repo = "wappalyzergo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L5DBXn96PK4Ed3MhmIgfVDLniGWgB/iogI+HKzfsvvA=";
  };

  strictDeps = true;
  vendorHash = "sha256-9MUhivdlbxAhcdbLALdt6vhxvMLzm+WincF3iG9pR1A=";
  __structuredAttrs = true;
  ldflags = [ "-s" ];

  meta = {
    description = "Implementation of the Wappalyzer Technology Detection Library";
    homepage = "https://github.com/projectdiscovery/wappalyzergo";
    changelog = "https://github.com/projectdiscovery/wappalyzergo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "wappalyzergo";
  };
})
