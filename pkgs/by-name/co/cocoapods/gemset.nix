{
  CFPropertyList = {
    version = "3.0.7";

    dependencies = [
      "base64"
      "nkf"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k1w5i4lb1z941m7ds858nly33f3iv12wvr1zav5x3fa99hj2my4";
      type = "gem";
    };
  };

  activesupport = {
    version = "7.2.2";

    dependencies = [
      "base64"
      "benchmark"
      "bigdecimal"
      "concurrent-ruby"
      "connection_pool"
      "drb"
      "i18n"
      "logger"
      "minitest"
      "securerandom"
      "tzinfo"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12ijz1mmg70agw4d91hjdyzvma3dzs52mchasslxyn7p9j960qs3";
      type = "gem";
    };
  };

  addressable = {
    version = "2.8.7";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cl2qpvwiffym62z991ynks7imsm87qmgxf0yfsmlwzkgi9qcaa6";
      type = "gem";
    };
  };

  algoliasearch = {
    version = "1.27.5";

    dependencies = [
      "httpclient"
      "json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ly8zsgvih540xmxr098hsngv61cf119wf28q5hbvi1f7kgwvh96";
      type = "gem";
    };
  };

  atomos = {
    version = "0.1.3";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17vq6sjyswr5jfzwdccw748kgph6bdw30bakwnn6p8sl4hpv4hvx";
      type = "gem";
    };
  };

  base64 = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01qml0yilb9basf7is2614skjp8384h2pycfx86cr8023arfj98g";
      type = "gem";
    };
  };

  benchmark = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wghmhwjzv4r9mdcny4xfz2h2cm7ci24md79rvy2x65r4i99k9sc";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "3.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
      type = "gem";
    };
  };

  claide = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bpqhc0kqjp1bh9b7ffc395l9gfls0337rrhmab4v46ykl45qg3d";
      type = "gem";
    };
  };

  cocoapods = {
    version = "1.16.2";

    dependencies = [
      "addressable"
      "claide"
      "cocoapods-core"
      "cocoapods-deintegrate"
      "cocoapods-downloader"
      "cocoapods-plugins"
      "cocoapods-search"
      "cocoapods-trunk"
      "cocoapods-try"
      "colored2"
      "escape"
      "fourflusher"
      "gh_inspector"
      "molinillo"
      "nap"
      "ruby-macho"
      "xcodeproj"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0phyvpx78jlrpvldbxjmzq92mfx6l66va2fz2s5xpwrdydhciw8g";
      type = "gem";
    };
  };

  cocoapods-core = {
    version = "1.16.2";

    dependencies = [
      "activesupport"
      "addressable"
      "algoliasearch"
      "concurrent-ruby"
      "fuzzy_match"
      "nap"
      "netrc"
      "public_suffix"
      "typhoeus"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ay1dwjg79rfa6mbfyy96in0k364dgn7s8ps6v7n07k9432bbcab";
      type = "gem";
    };
  };

  cocoapods-deintegrate = {
    version = "1.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18pnng0lv5z6kpp8hnki0agdxx979iq6hxkfkglsyqzmir22lz2i";
      type = "gem";
    };
  };

  cocoapods-downloader = {
    version = "2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ldnwwsx44i2xsdmsmyz9xrar19lfy5s5xslvral1p3674dvwvmv";
      type = "gem";
    };
  };

  cocoapods-plugins = {
    version = "1.0.0";
    dependencies = [ "nap" ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16na82sfyc8801qs1n22nwq486s4j7yj6rj7fcp8cbxmj371fpbj";
      type = "gem";
    };
  };

  cocoapods-search = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12amy0nknv09bvzix8bkmcjn996c50c4ms20v2dl7v8rcw73n4qv";
      type = "gem";
    };
  };

  cocoapods-trunk = {
    version = "1.6.0";

    dependencies = [
      "nap"
      "netrc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cgdx7z9psxxrsa13fk7qc9i6jskrwcafhrdz94avzia2y6dlnsz";
      type = "gem";
    };
  };

  cocoapods-try = {
    version = "1.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1znyp625rql37ivb5rk9fk9564cmax8icxfr041ysivpdrn98nql";
      type = "gem";
    };
  };

  colored2 = {
    version = "3.1.2";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jlbqa9q4mvrm73aw9mxh23ygzbjiqwisl32d8szfb5fxvbjng5i";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0chwfdq2a6kbj6xz9l6zrdfnyghnh32si82la1dnpa5h75ir5anl";
      type = "gem";
    };
  };

  connection_pool = {
    version = "2.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x32mcpm2cl5492kd6lbjbaf17qsssmpx9kdyr7z1wcif2cwyh0g";
      type = "gem";
    };
  };

  drb = {
    version = "2.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h5kbj9hvg5hb3c7l425zpds0vb42phvln2knab8nmazg2zp5m79";
      type = "gem";
    };
  };

  escape = {
    version = "0.0.4";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sa1xkfc9jvkwyw1jbz3jhkq0ms1zrvswi6mmfiwcisg5fp497z4";
      type = "gem";
    };
  };

  ethon = {
    version = "0.16.0";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17ix0mijpsy3y0c6ywrk5ibarmvqzjsirjyprpsy3hwax8fdm85v";
      type = "gem";
    };
  };

  ffi = {
    version = "1.17.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07139870npj59jnl8vmk39ja3gdk3fb5z9vc0lf32y2h891hwqsi";
      type = "gem";
    };
  };

  fourflusher = {
    version = "2.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1afabh3g3gwj0ad53fs62waks815xcckf7pkci76l6vrghffcg8v";
      type = "gem";
    };
  };

  fuzzy_match = {
    version = "2.0.4";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19gw1ifsgfrv7xdi6n61658vffgm1867f4xdqfswb2b5h6alzpmm";
      type = "gem";
    };
  };

  gh_inspector = {
    version = "1.1.3";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f8r9byajj3bi2c7c5sqrc7m0zrv3nblfcd4782lw5l73cbsgk04";
      type = "gem";
    };
  };

  httpclient = {
    version = "2.8.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.6";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k31wcgnvcvd14snz0pfqj976zv6drfsnq6x8acz10fiyms9l8nw";
      type = "gem";
    };
  };

  json = {
    version = "2.7.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03q7kbadhbyfnz21abv2b9dyqnjvxpd51ppqihg40rrimw1vm6id";
      type = "gem";
    };
  };

  logger = {
    version = "1.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lwncq2rf8gm79g2rcnnyzs26ma1f4wnfjm6gs4zf2wlsdz5in9s";
      type = "gem";
    };
  };

  minitest = {
    version = "5.25.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n1akmc6bibkbxkzm1p1wmfb4n9vv397knkgz0ffykb3h1d7kdix";
      type = "gem";
    };
  };

  molinillo = {
    version = "0.8.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p846facmh1j5xmbrpgzadflspvk7bzs3sykrh5s7qi4cdqz5gzg";
      type = "gem";
    };
  };

  nanaimo = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08q73nchv8cpk28h1sdnf5z6a862fcf4mxy1d58z25xb3dankw7s";
      type = "gem";
    };
  };

  nap = {
    version = "1.1.0";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xm5xssxk5s03wjarpipfm39qmgxsalb46v1prsis14x1xk935ll";
      type = "gem";
    };
  };

  netrc = {
    version = "0.11.0";

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
  };

  nkf = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09piyp2pd74klb9wcn0zw4mb5l0k9wzwppxggxi1yi95l2ym3hgv";
      type = "gem";
    };
  };

  public_suffix = {
    version = "4.0.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f3knlwfwm05sfbaihrxm4g772b79032q14c16q4b38z8bi63qcb";
      type = "gem";
    };
  };

  rexml = {
    version = "3.3.9";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j9p66pmfgxnzp76ksssyfyqqrg7281dyi3xyknl3wwraaw7a66p";
      type = "gem";
    };
  };

  ruby-macho = {
    version = "2.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jgmhj4srl7cck1ipbjys6q4klcs473gq90bm59baw4j1wpfaxch";
      type = "gem";
    };
  };

  securerandom = {
    version = "0.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1phv6kh417vkanhssbjr960c0gfqvf8z7d3d9fd2yvd41q64bw4q";
      type = "gem";
    };
  };

  typhoeus = {
    version = "1.4.1";
    dependencies = [ "ethon" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z7gamf6s83wy0yqms3bi4srirn3fc0lc7n65lqanidxcj1xn5qw";
      type = "gem";
    };
  };

  tzinfo = {
    version = "2.0.6";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
  };

  xcodeproj = {
    version = "1.27.0";

    dependencies = [
      "CFPropertyList"
      "atomos"
      "claide"
      "colored2"
      "nanaimo"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lslz1kfb8jnd1ilgg02qx0p0y6yiq8wwk84mgg2ghh58lxsgiwc";
      type = "gem";
    };
  };
}
