{
  abbrev = {
    version = "0.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hj2qyx7rzpc7awhvqlm597x7qdxwi4kkml4aqnp5jylmsm4w6xd";
      type = "gem";
    };
  };

  highline = {
    version = "2.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f8cr014j7mdqpdb9q17fp5vb5b8n1pswqaif91s3ylg5x3pygfn";
      type = "gem";
    };
  };

  json_pure = {
    version = "2.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kks889ymaq5xqvj18qamar3il8m3dnnaf6cij0a0kwxp8lpk1va";
      type = "gem";
    };
  };

  thor = {
    version = "1.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nmymd86a0vb39pzj2cwv57avdrl6pl3lf5bsz58q594kqxjkw7f";
      type = "gem";
    };
  };

  vimgolf = {
    version = "0.5.0";

    dependencies = [
      "highline"
      "json_pure"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "190dzqkvshd4i6jf30xnpm4sczraw6rdh4wvfh6qnmg0czmj0sny";
      type = "gem";
    };
  };
}
