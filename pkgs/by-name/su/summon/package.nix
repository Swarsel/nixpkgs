{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "summon";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "cyberark";
    repo = "summon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qJBJ5zxILl9lxPH67j6r2H7K8WRpKZo5vqe4nIaL35w=";
  };

  vendorHash = "sha256-7fyHgbmP+lm1F3wGKrNvhaWyLk10aIu4JSRqSZeGrdU=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/summon
  '';

  subPackages = [ "cmd" ];

  meta = {
    description = "CLI that provides on-demand secrets access for common DevOps tools";
    homepage = "https://cyberark.github.io/summon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ quentini ];
    mainProgram = "summon";
  };
})
