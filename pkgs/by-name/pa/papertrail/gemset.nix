{
  ansi = {
    version = "1.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14ims9zfal4gs2wpx2m5rd8zsrl2k794d359shkrsgg3fhr2a22l";
      type = "gem";
    };
  };

  chronic = {
    version = "0.10.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hrdkn4g8x7dlzxwb1rfgr8kw3bp4ywg5l4y4i9c2g5cwv62yvvn";
      type = "gem";
    };
  };

  papertrail = {
    version = "0.11.2";

    dependencies = [
      "ansi"
      "chronic"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "170zhgahrgpwj4cb9xj8104yqcf9gva8qk5vqpmw3g8rq29jxshy";
      type = "gem";
    };
  };
}
