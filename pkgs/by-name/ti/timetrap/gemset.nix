{
  bigdecimal = {
    version = "3.1.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k6qzammv9r6b2cw3siasaik18i6wjc5m0gw5nfdc6jj64h79z1g";
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

  mini_portile2 = {
    version = "2.8.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x8asxl83msn815lwmb2d7q5p29p7drhjv5va0byhk60v9n16iwf";
      type = "gem";
    };
  };

  sequel = {
    version = "5.90.0";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s5qhylirrmfbjhdjdfqaiksjlaqmgixl25sxd8znq8dqwqlrydz";
      type = "gem";
    };
  };

  sqlite3 = {
    version = "1.7.3";
    dependencies = [ "mini_portile2" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "073hd24qwx9j26cqbk0jma0kiajjv9fb8swv9rnz8j4mf0ygcxzs";
      type = "gem";
    };
  };

  timetrap = {
    version = "1.15.5";

    dependencies = [
      "chronic"
      "sequel"
      "sqlite3"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gcs9vyg1i3nsiiwrkqza14qj7h3chlg6w5icbf0ggjzswz3rwd2";
      type = "gem";
    };
  };
}
