{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "m-cli";
  version = "2.0.9";

  src = fetchFromGitHub {
    owner = "rgcr";
    repo = "m-cli";
    tag = "v${version}";
    sha256 = "sha256-Esq7ECkl34L+hk5jGS3pTmUu9vnI9hfn0Q+w0/AbvgY=";
  };

  installPhase = ''
    local MPATH="$out/share/m"

    gawk -i inplace '{
      gsub(/^\[ -L.*|^\s+\|\| pushd.*|^popd.*/, "");
      gsub(/MPATH=.*/, "MPATH='$MPATH'");
      gsub(/(update|uninstall)_mcli \&\&.*/, "echo NOOP \\&\\& exit 0");
      gsub(/get_version \&\&.*/, "echo m-cli version: ${version} \\&\\& exit 0");
      print
    }' m

    install -Dt "$out/bin/plugins" -m755 plugins/*

    install -Dm755 m $out/bin/m

    install -Dt "$out/share/bash-completion/completions/" -m444 completions/bash/m
    install -Dt "$out/share/fish/vendor_completions.d/" -m444 completions/fish/m.fish
    install -Dt "$out/share/zsh/site-functions/" -m444 completions/zsh/_m
  '';

  dontBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (src.meta) homepage;
    description = "Swiss Army Knife for macOS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anish ];
    platforms = lib.platforms.darwin;
    mainProgram = "m";
  };
}
