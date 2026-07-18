{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  makeWrapper,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "krew";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "krew";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rhl4qVHwl876OSDrcLSS07x3H/x/zmFLPHdRw+fcYsw=";
    leaveDotGit = true;

    postFetch = ''
      git -C "$out" rev-parse --short HEAD > "$out/.git_head"
      rm -rf "$out/.git"
    '';
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-z0wiYknXcCx4vqROngn58CRe9TBgya4y3v736VBMhQ8=";

  preBuild = ''
    ldflags+=" -X=sigs.k8s.io/krew/internal/version.gitCommit=$(<.git_head)"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  postFixup = ''
    wrapProgram $out/bin/krew \
      --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
  '';

  ldflags = [
    "-s"
    "-X"
    "sigs.k8s.io/krew/internal/version.gitTag=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/krew" ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Package manager for kubectl plugins";
    homepage = "https://github.com/kubernetes-sigs/krew";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vdemeester ];
    mainProgram = "krew";
  };
})
