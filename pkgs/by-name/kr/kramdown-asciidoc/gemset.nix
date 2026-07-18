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

  kramdown-asciidoc = {
    version = "2.1.0";

    dependencies = [
      "kramdown"
      "kramdown-parser-gfm"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j7qbpq6zhgcf9ykhz5r1wlr3r8fls6hvhdisxzz4v35rni5kwp9";
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
}
