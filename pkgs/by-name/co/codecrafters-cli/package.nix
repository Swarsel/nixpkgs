{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
}:

buildGoModule (finalAttrs: {
  pname = "codecrafters-cli";
  version = "54";

  src = fetchFromGitHub {
    owner = "codecrafters-io";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f8tasK6pWML2lbngf+1u8YQqWvRmHH9yLiiLhsCpiJY=";
    # A shortened git commit hash is part of the version output, and is
    # needed at build time. Use the `.git` directory to retrieve the
    # commit SHA, and remove the directory afterwards since it is not needed
    # after that.
    leaveDotGit = true;

    postFetch = ''
      git -C $"$out" rev-parse --short=7 HEAD > $out/COMMIT
      rm -rf $out/.git
    '';
  };

  nativeBuildInputs = [ git ];
  vendorHash = "sha256-LfchGzJPgPVa4wTXoViIEx8B17HMoPPME/2RLkatGUQ=";

  # ldflags based on metadata from git
  preBuild = ''
    ldflags+=" -X github.com/codecrafters-io/cli/internal/utils.Commit=$(cat COMMIT)"
  '';

  # We need to disable tests because the tests for respecting .gitignore
  # include setting up a global gitignore which doesn't work.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/codecrafters-io/cli/internal/utils.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "CodeCrafters CLI to run tests";
    homepage = "https://github.com/codecrafters-io/cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ builditluc ];
    mainProgram = "codecrafters";
  };
})
