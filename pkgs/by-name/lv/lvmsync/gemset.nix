{
  git-version-bump = {
    version = "0.15.1";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xcj20gmbpqn2gcpid4pxpnimfdg2ip9jnl1572naz0magcrwl2s";
      type = "gem";
    };
  };

  lvmsync = {
    version = "3.3.2";

    dependencies = [
      "git-version-bump"
      "treetop"
    ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02mdrvfibvab4p4yrdzxvndhy8drss3ri7izybcwgpbyc7isk8mv";
      type = "gem";
    };
  };

  polyglot = {
    version = "0.3.5";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bqnxwyip623d8pr29rg6m8r0hdg08fpr2yb74f46rn1wgsnxmjr";
      type = "gem";
    };
  };

  treetop = {
    version = "1.6.9";
    dependencies = [ "polyglot" ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sdkd1v2h8dhj9ncsnpywmqv7w1mdwsyc5jwyxlxwriacv8qz8bd";
      type = "gem";
    };
  };
}
