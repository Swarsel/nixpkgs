{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  testers,
}:

# this expression is mostly automated, and you are STRONGLY
# RECOMMENDED to use to nix-update for updating this expression when new
# releases come out, which runs the sibling `update.sh` script.
#
# from the root of the nixpkgs git repository, run:
#
#    nix-shell maintainers/scripts/update.nix \
#      --arg commit true \
#      --argstr package infisical

let
  # build hashes, which correspond to the hashes of the precompiled binaries procured by GitHub Actions.
  buildHashes = builtins.fromJSON (builtins.readFile ./hashes.json);

  # the version of infisical
  version = "0.41.90";

  # the platform-specific, statically linked binary
  src =
    let
      suffix =
        {
          aarch64-darwin = "darwin_arm64";
          aarch64-linux = "linux_arm64";
          # map the platform name to the golang toolchain suffix
          # NOTE: must be synchronized with update.sh!
          x86_64-linux = "linux_amd64";
        }
        ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

      name = "infisical_${version}_${suffix}.tar.gz";
      hash = buildHashes."${stdenv.hostPlatform.system}";
      url = "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${version}/${name}";
    in
    fetchurl { inherit name url hash; };

in
stdenv.mkDerivation (finalAttrs: {
  inherit src;
  pname = "infisical";
  version = version;
  nativeBuildInputs = [ installShellFiles ];
  buildPhase = "chmod +x ./infisical";
  doCheck = true;
  checkPhase = "./infisical --version";

  installPhase = ''
    mkdir -p $out/bin/ $out/share/completions/ $out/share/man/
    cp infisical $out/bin
    cp completions/* $out/share/completions/
    cp manpages/* $out/share/man/
  '';

  postInstall = ''
    installManPage share/man/infisical.1.gz
    installShellCompletion share/completions/infisical.{bash,fish,zsh}
  '';

  dontConfigure = true;
  dontStrip = true;
  sourceRoot = ".";

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Official Infisical CLI";

    longDescription = ''
      Infisical is the open-source secret management platform:
      Sync secrets across your team/infrastructure and prevent secret leaks.
    '';

    homepage = "https://infisical.com";
    changelog = "https://github.com/infisical/infisical/releases/tag/infisical-cli%2Fv${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hausken ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "infisical";
    teams = [ lib.teams.infisical ];
  };
})
