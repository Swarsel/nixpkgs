{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "headplane-agent";
  # Note, if you are upgrading this, you should upgrade headplane at the same time
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "tale";
    repo = "headplane";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zvJUTKRIlHyPMq80teVXBSb7K9Zz44Kuuj2PPi6qIOw=";
  };

  vendorHash = "sha256-MvrqKMD+A+qBZmzQv+T9920U5uJop+pjfJpZdm2ZqEA=";
  env.CGO_ENABLED = 0;
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/hp_agent" ];

  meta = {
    description = "Optional sidecar process providing additional features for headplane";
    homepage = "https://github.com/tale/headplane";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      igor-ramazanov
      stealthbadger747
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "hp_agent";
  };
})
