{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  fetchPnpmDeps,
  makeWrapper,
  net-tools,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:

let
  pnpm = pnpm_10;

  version = "0.63.17";

  src = fetchFromGitHub {
    owner = "pommee";
    repo = "goaway";
    tag = "v${version}";
    hash = "sha256-cRx7XN8eaxqqI5+CWF93U4rgP8sH3HY4MPOA6VtqXK8=";
  };

  goaway-web = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version src;
    pname = "goaway-web";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      runHook preBuild

      pnpm -C client build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r client/dist $out

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-GM86Os1OQaagD61BEIIsqhWJNVPFA9Z5RiYWyHlQlwY=";
      sourceRoot = "${finalAttrs.src.name}/client";
    };

    pnpmRoot = "client";

  });
in
buildGo126Module (finalAttrs: {
  inherit
    version
    src
    goaway-web
    ;

  pname = "goaway";
  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-tSTvySLBo9cM9+Ul45TrGDruTllE/HWLdYmzqMDIYEQ=";

  preBuild = ''
    rm -rf client/dist
    cp -r ${goaway-web} client/dist
  '';

  postInstall = ''
    wrapProgram $out/bin/goaway \
     --prefix PATH : $out/bin:${lib.makeBinPath [ net-tools ]}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.src.tag}"
    "-X=main.commit=${finalAttrs.src.tag}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  meta = {
    description = "Lightweight DNS sinkhole written in Go with a modern dashboard client";
    homepage = "https://github.com/pommee/goaway";
    changelog = "https://github.com/pommee/goaway/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "goaway";
  };
})
