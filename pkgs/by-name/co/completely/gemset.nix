{
  colsole = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fvf6dz2wsvjk7q24z0dm8lajq3p2l6i5ywf3mxj683rmhwq49bg";
      type = "gem";
    };
  };

  completely = {
    version = "0.7.1";

    dependencies = [
      "colsole"
      "mister_bin"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0129alz54h2vy7vd19i5664sasdbvrl4zgj70hl5j4rpvckr5lf8";
      type = "gem";
    };
  };

  docopt_ng = {
    version = "0.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rsnl5s7k2s1gl4n4dg68ssg577kf11sl4a4l2lb2fpswj718950";
      type = "gem";
    };
  };

  mister_bin = {
    version = "0.8.1";

    dependencies = [
      "colsole"
      "docopt_ng"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zz3vpy6xrgzln2dpxgcnrq1bpzz0syl60whqc9zf8j29mayw1fy";
      type = "gem";
    };
  };
}
