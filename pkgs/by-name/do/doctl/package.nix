{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "doctl";
  version = "1.160.1";

  src = fetchFromGitHub {
    owner = "digitalocean";
    repo = "doctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M+DBJfUXymlzY9DJeyHl3SPaCIKCT2iN/I4rd3uyQbQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  doCheck = false;

  postInstall = ''
    export HOME=$(mktemp -d) # attempts to write to /homeless-shelter
    for shell in bash fish zsh; do
      ${stdenv.hostPlatform.emulator buildPackages} $out/bin/doctl completion $shell > doctl.$shell
      installShellCompletion doctl.$shell
    done
  '';

  ldflags =
    let
      t = "github.com/digitalocean/doctl";
    in
    [
      "-X ${t}.Major=${lib.versions.major finalAttrs.version}"
      "-X ${t}.Minor=${lib.versions.minor finalAttrs.version}"
      "-X ${t}.Patch=${lib.versions.patch finalAttrs.version}"
      "-X ${t}.Label=release"
    ];

  subPackages = [ "cmd/doctl" ];

  meta = {
    description = "Command line tool for DigitalOcean services";
    homepage = "https://github.com/digitalocean/doctl";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.siddharthist ];
    mainProgram = "doctl";
  };
})
