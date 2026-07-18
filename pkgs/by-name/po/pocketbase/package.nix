{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "pocketbase";
  version = "0.39.6";

  src = fetchFromGitHub {
    owner = "pocketbase";
    repo = "pocketbase";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EQMgqdxssB4FbVJDoYZTdk9vq+++k52MJe/6ZiGgHjo=";
  };

  vendorHash = "sha256-Xu9jokD5Dkov5kZjO05q60YpM3NZlbwOZs0XJmQ8kC8=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/base $out/bin/pocketbase
  '';

  # Upstream build instructions
  ldflags = [
    "-s"
    "-w"
    "-X github.com/pocketbase/pocketbase.Version=${finalAttrs.version}"
  ];

  # This is the released subpackage from upstream repo
  subPackages = [ "examples/base" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open Source realtime backend in 1 file";
    homepage = "https://github.com/pocketbase/pocketbase";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      thilobillerbeck
    ];

    mainProgram = "pocketbase";
  };
})
