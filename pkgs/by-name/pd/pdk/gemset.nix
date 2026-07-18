{
  addressable = {
    version = "2.8.8";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mxhjgihzsx45l9wh2n0ywl9w0c6k70igm5r0d63dxkcagwvh4vw";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "3.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0612spks81fvpv2zrrv3371lbs6mwd7w6g5zafglyk75ici1x87a";
      type = "gem";
    };
  };

  childprocess = {
    version = "5.1.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v5nalaarxnfdm6rxb7q6fmc6nx097jd630ax6h9ch7xw95li3cs";
      type = "gem";
    };
  };

  cri = {
    version = "2.15.12";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rank6i9p2drwdcmhan6ifkzrz1v3mwpx47fwjl75rskxwjfkgwa";
      type = "gem";
    };
  };

  deep_merge = {
    version = "1.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fjn4civid68a3zxnbgyjj6krs3l30dy8b4djpg6fpzrsyix7kl3";
      type = "gem";
    };
  };

  diff-lcs = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mb3nfmnv5gyaxcw10fzdr4jrvx198bq38akiw7vai99xi95v2kh";
      type = "gem";
    };
  };

  faraday = {
    version = "2.14.1";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "077n5ss3z3ds4vj54w201kd12smai853dp9c9n7ii7g3q7nwwg54";
      type = "gem";
    };
  };

  faraday-follow_redirects = {
    version = "0.3.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1y87p3yk15bjbk0z9mf01r50lzxvp7agr56lbm9gxiz26mb9fbfr";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.2";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v4hfmc7d4lrqqj2wl366rm9551gd08zkv2ppwwnjlnkc217aizi";
      type = "gem";
    };
  };

  ffi = {
    version = "1.17.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k1xaqw2jk13q3ss7cnyvkp8fzp75dk4kazysrxgfd1rpgvkk7qf";
      type = "gem";
    };
  };

  hitimes = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ix9rp9rsrwin38z2aqiwpxc8p2dzl6m3ra47az47fsija1cb2qf";
      type = "gem";
    };
  };

  json = {
    version = "2.18.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11prr7nrxh1y4rfsqa51gy4ixx63r18cz9mdnmk0938va1ajf4gy";
      type = "gem";
    };
  };

  json-schema = {
    version = "5.2.2";

    dependencies = [
      "addressable"
      "bigdecimal"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ma0k5889hzydba2ci8lqg87pxsh9zabz7jchm9cbacwsw7axgk0";
      type = "gem";
    };
  };

  logger = {
    version = "1.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
  };

  minitar = {
    version = "0.12.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f307mpj4j0gp7iq77xj4p149f4krcvbll9rismng3jcijpbn79s";
      type = "gem";
    };
  };

  net-http = {
    version = "0.9.1";
    dependencies = [ "uri" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15k96fj6qwbaiv6g52l538ass95ds1qwgynqdridz29yqrkhpfi5";
      type = "gem";
    };
  };

  pastel = {
    version = "0.8.0";
    dependencies = [ "tty-color" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xash2gj08dfjvq4hy6l1z22s5v30fhizwgs10d6nviggpxsj7a8";
      type = "gem";
    };
  };

  pathspec = {
    version = "1.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08sxih7jrx07rczg3rpw7h9dawr43rxc68afhy498j8r816gzry4";
      type = "gem";
    };
  };

  pdk = {
    version = "3.4.0";

    dependencies = [
      "childprocess"
      "cri"
      "deep_merge"
      "diff-lcs"
      "ffi"
      "hitimes"
      "json-schema"
      "minitar"
      "pathspec"
      "puppet-modulebuilder"
      "puppet_forge"
      "tty-prompt"
      "tty-spinner"
      "tty-which"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pcwygvs85rnqndn3b64mxbgcs1yb628z5cg9hwwjaxf5wds37vi";
      type = "gem";
    };
  };

  public_suffix = {
    version = "7.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mx84s7gn3xabb320hw8060v7amg6gmcyyhfzp0kawafiq60j54i";
      type = "gem";
    };
  };

  puppet-modulebuilder = {
    version = "1.1.0";

    dependencies = [
      "minitar"
      "pathspec"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rh31hq24nkddd83cx7n9ln5bsib3a052hrmn120sq0937337173";
      type = "gem";
    };
  };

  puppet_forge = {
    version = "5.0.4";

    dependencies = [
      "faraday"
      "faraday-follow_redirects"
      "minitar"
      "semantic_puppet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d65zri1nmpph8iki5iigdzfqd6rfyc1mlgdfhg69q3566rcff06";
      type = "gem";
    };
  };

  semantic_puppet = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ksbizvakfx0zfdgjbh34hqnrnkjj47m4kbnsg58mpqsx45pzqm";
      type = "gem";
    };
  };

  tty-color = {
    version = "0.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aik4kmhwwrmkysha7qibi2nyzb4c8kp42bd5vxnf8sf7b53g73g";
      type = "gem";
    };
  };

  tty-cursor = {
    version = "0.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
  };

  tty-prompt = {
    version = "0.23.1";

    dependencies = [
      "pastel"
      "tty-reader"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j4y8ik82azjxshgd4i1v4wwhsv3g9cngpygxqkkz69qaa8cxnzw";
      type = "gem";
    };
  };

  tty-reader = {
    version = "0.9.0";

    dependencies = [
      "tty-cursor"
      "tty-screen"
      "wisper"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cf2k7w7d84hshg4kzrjvk9pkyc2g1m3nx2n1rpmdcf0hp4p4af6";
      type = "gem";
    };
  };

  tty-screen = {
    version = "0.8.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l4vh6g333jxm9lakilkva2gn17j6gb052626r1pdbmy2lhnb460";
      type = "gem";
    };
  };

  tty-spinner = {
    version = "0.9.3";
    dependencies = [ "tty-cursor" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hh5awmijnzw9flmh5ak610x1d00xiqagxa5mbr63ysggc26y0qf";
      type = "gem";
    };
  };

  tty-which = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rpljdwlfm4qgps2xvq6306w86fm057m89j4gizcji371mgha92q";
      type = "gem";
    };
  };

  uri = {
    version = "1.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ijpbj7mdrq7rhpq2kb51yykhrs2s54wfs6sm9z3icgz4y6sb7rp";
      type = "gem";
    };
  };

  wisper = {
    version = "2.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rpsi0ziy78cj82sbyyywby4d0aw0a5q84v65qd28vqn79fbq5yf";
      type = "gem";
    };
  };
}
