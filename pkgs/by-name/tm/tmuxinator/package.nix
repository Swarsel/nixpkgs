{
  lib,
  buildRubyGem,
  installShellFiles,
  ruby,
}:

# Cannot use bundleEnv because bundleEnv create stub with
# BUNDLE_FROZEN='1' environment variable set, which broke everything
# that rely on Bundler that runs under Tmuxinator.

buildRubyGem rec {
  inherit ruby;
  version = "3.3.7";
  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = [
    erubi
    thor
    xdg
  ];

  postInstall = ''
    installShellCompletion $GEM_HOME/gems/${gemName}-${version}/completion/tmuxinator.{bash,zsh,fish}
  '';

  erubi = buildRubyGem rec {
    inherit ruby;
    version = "1.13.0";
    gemName = "erubi";
    name = "ruby${ruby.version}-${gemName}-${version}";
    source.sha256 = "fca61b47daefd865d0fb50d168634f27ad40181867445badf6427c459c33cd62";
  };

  gemName = "tmuxinator";
  name = "${gemName}-${version}";
  source.sha256 = "sha256-z0E/zS6o8MXW4Gi6KqtusRtPpUBa5XhGMAsNJGZxL7I=";

  thor = buildRubyGem rec {
    inherit ruby;
    version = "1.4.0";
    gemName = "thor";
    name = "ruby${ruby.version}-${gemName}-${version}";
    source.sha256 = "sha256-h2PoIsyw8de+6IzeExsZplYGZXuEfMe3tLgudyvNij0=";
  };

  xdg = buildRubyGem rec {
    inherit ruby;
    version = "2.2.5";
    gemName = "xdg";
    name = "ruby${ruby.version}-${gemName}-${version}";
    source.sha256 = "04xr4cavnzxlk926pkji7b5yiqy4qsd3gdvv8mg6jliq6sczg9gk";
  };

  meta = {
    description = "Manage complex tmux sessions easily";
    homepage = "https://github.com/tmuxinator/tmuxinator";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      auntie
    ];

    platforms = lib.platforms.unix;
    mainProgram = "tmuxinator";
  };
}
