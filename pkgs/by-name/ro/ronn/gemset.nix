{
  kramdown = {
    version = "2.4.0";
    dependencies = [ "rexml" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ic14hdcqxn821dvzki99zhmcy130yhv5fqfffkcf87asv5mnbmn";
      type = "gem";
    };
  };

  kramdown-parser-gfm = {
    version = "1.1.0";
    dependencies = [ "kramdown" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a8pb3v951f4x7h968rqfsa19c8arz21zw1vaj42jza22rap8fgv";
      type = "gem";
    };
  };

  mini_portile2 = {
    version = "2.8.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kl9c3kdchjabrihdqfmcplk3lq4cw1rr9f378y6q22qwy5dndvs";
      type = "gem";
    };
  };

  mustache = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l0p4wx15mi3wnamfv92ipkia4nsx8qi132c6g51jfdma3fiz2ch";
      type = "gem";
    };
  };

  nokogiri = {
    version = "1.16.0";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1l8b0i24h4irivyhwy9xmkjbggw86cxkzkiqdqg0jpcp9qc8h4rl";
      type = "gem";
    };
  };

  racc = {
    version = "1.7.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01b9662zd2x9bp4rdjfid07h09zxj7kvn7f5fghbqhzc625ap1dp";
      type = "gem";
    };
  };

  rexml = {
    version = "3.2.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05i8518ay14kjbma550mv0jm8a6di8yp5phzrd8rj44z9qnrlrp0";
      type = "gem";
    };
  };

  ronn-ng = {
    version = "0.10.1";

    dependencies = [
      "kramdown"
      "kramdown-parser-gfm"
      "mustache"
      "nokogiri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h2y2v3wkl5c710wfanqwxlxi74l1ssva8yrzsg8iypvq22h3ssf";
      type = "gem";
    };
  };
}
