{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "hishtory";
  version = "0.335";

  src = fetchFromGitHub {
    owner = "ddworken";
    repo = "hishtory";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nh3dNm+5h+3moeO1PUS6tPkftojMSSWSr0m/5n2iO2w=";
  };

  vendorHash = "sha256-tJjhHZT91vomGLM4IjMYBD4WfKo7eBcGu/osL6NTMwc=";
  doCheck = true;

  postInstall = ''
    mkdir -p $out/share/hishtory
    cp client/lib/config.* $out/share/hishtory
  '';

  excludedPackages = [ "backend/server" ];
  ldflags = [ "-X github.com/ddworken/hishtory/client/lib.Version=${finalAttrs.version}" ];
  subPackages = [ "." ];

  meta = {
    description = "Your shell history: synced, queryable, and in context";
    homepage = "https://github.com/ddworken/hishtory";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "hishtory";
  };
})
