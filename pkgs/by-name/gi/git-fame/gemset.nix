{
  activesupport = {
    version = "8.0.2";

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
      "uri"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pm40y64wfc50a9sj87kxvil2102rmpdcbv82zf0r40vlgdwsrc5";
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
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jl71qcgamm96dzyqk695j24qszhcc7liw74qc83fpjljp2gh4hg";
      type = "gem";
    };
  };

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

  concurrent-ruby = {
    version = "1.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ipbrgvf0pp6zxdk5ascp6i29aybz2bx9wdrlchjmpx6mhvkwfw1";
      type = "gem";
    };
  };

  connection_pool = {
    version = "2.5.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nrhsk7b3sjqbyl1cah6ibf1kvi3v93a7wf4637d355hp614mmyg";
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

  dry-core = {
    version = "1.1.0";

    dependencies = [
      "concurrent-ruby"
      "logger"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15di39ssfkwigyyqla65n4x6cfhgwa4cv8j5lmyrlr07jwd840q9";
      type = "gem";
    };
  };

  dry-inflector = {
    version = "1.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0blgyg9l4gpzhb7rs9hqq9j7br80ngiigjp2ayp78w6m1ysx1x92";
      type = "gem";
    };
  };

  dry-initializer = {
    version = "3.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qy4cv0j0ahabprdbp02nc3r1606jd5dp90lzqg0mp0jz6c9gm9p";
      type = "gem";
    };
  };

  dry-logic = {
    version = "1.6.0";

    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18nf8mbnhgvkw34drj7nmvpx2afmyl2nyzncn3wl3z4h1yyfsvys";
      type = "gem";
    };
  };

  dry-struct = {
    version = "1.8.0";

    dependencies = [
      "dry-core"
      "dry-types"
      "ice_nine"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ri9iqxknxvvhpbshf6jn7bq581k8l67iv23mii69yr4k5aqphvl";
      type = "gem";
    };
  };

  dry-types = {
    version = "1.8.2";

    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "dry-inflector"
      "dry-logic"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03zcngwfpq0nx9wmxma0s1c6sb3xxph93q8j7dy75721d7d9lkn8";
      type = "gem";
    };
  };

  equatable = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sjm9zjakyixyvsqziikdrsqfzis6j3fq23crgjkp6fwkfgndj7x";
      type = "gem";
    };
  };

  git_fame = {
    version = "3.2.19";

    dependencies = [
      "activesupport"
      "dry-initializer"
      "dry-struct"
      "dry-types"
      "neatjson"
      "rugged"
      "tty-box"
      "tty-option"
      "tty-screen"
      "tty-spinner"
      "tty-table"
      "zeitwerk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1891k7v2ld5p9v9zlc80s7qkqdxs1wpw6m40gx1wr273n177jal8";
      type = "gem";
    };
  };

  i18n = {
    version = "1.14.7";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03sx3ahz1v5kbqjwxj48msw3maplpp2iyzs22l4jrzrqh4zmgfnf";
      type = "gem";
    };
  };

  ice_nine = {
    version = "0.11.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nv35qg1rps9fsis28hz2cq2fx1i96795f91q4nmkm934xynll2x";
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

  minitest = {
    version = "5.25.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mn7q9yzrwinvfvkyjiz548a4rmcwbmz2fn9nyzh4j1snin6q6rr";
      type = "gem";
    };
  };

  neatjson = {
    version = "0.10.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wm1lq8yl6rzysh3wg6fa55w5534k6ppiz0qb7jyvdy582mk5i0s";
      type = "gem";
    };
  };

  necromancer = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v9nhdkv6zrp7cn48xv7n2vjhsbslpvs0ha36mfkcd56cp27pavz";
      type = "gem";
    };
  };

  pastel = {
    version = "0.7.2";

    dependencies = [
      "equatable"
      "tty-color"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yf30d9kzpm96gw9kwbv31p0qigwfykn8qdis5950plnzgc1vlp1";
      type = "gem";
    };
  };

  rugged = {
    version = "1.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b7gcf6pxg4x607bica68dbz22b4kch33yi0ils6x3c8ql9akakz";
      type = "gem";
    };
  };

  securerandom = {
    version = "0.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cd0iriqfsf1z91qg271sm88xjnfd92b832z49p1nd542ka96lfc";
      type = "gem";
    };
  };

  strings = {
    version = "0.1.8";

    dependencies = [
      "strings-ansi"
      "unicode-display_width"
      "unicode_utils"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "111876lcqrykh30w7zzkrl06d6rj9lq24y625m28674vgfxkkcz0";
      type = "gem";
    };
  };

  strings-ansi = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "120wa6yjc63b84lprglc52f40hx3fx920n4dmv14rad41rv2s9lh";
      type = "gem";
    };
  };

  tty-box = {
    version = "0.5.0";

    dependencies = [
      "pastel"
      "strings"
      "tty-cursor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14g63v0jx87hba50rlv3c521zg9rw0f5d31cihcvym19xxa7v3l5";
      type = "gem";
    };
  };

  tty-color = {
    version = "0.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zz5xa6xbrj69h334d8nx7z732fz80s1a0b02b53mim95p80s7bk";
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

  tty-option = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "019ir4bcr8fag7dmq7ph6ilpvwjbv4qalip0bz7dlddbd6fk4vjs";
      type = "gem";
    };
  };

  tty-screen = {
    version = "0.6.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0azpjgyhdm8ycblnx9crq3dgb2x8yg454a13n60zfpsc0n138sw1";
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

  tty-table = {
    version = "0.10.0";

    dependencies = [
      "equatable"
      "necromancer"
      "pastel"
      "strings"
      "tty-screen"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05krrj1x5pmfbz74paszrsr1316w9b9jlc4wpd9s9gpzqfzwjzcg";
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

  unicode-display_width = {
    version = "1.8.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1204c1jx2g89pc25qk5150mk7j5k90692i7ihgfzqnad6qni74h2";
      type = "gem";
    };
  };

  unicode_utils = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
      type = "gem";
    };
  };

  uri = {
    version = "1.0.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04bhfvc25b07jaiaf62yrach7khhr5jlr5bx6nygg8pf11329wp9";
      type = "gem";
    };
  };

  zeitwerk = {
    version = "2.7.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ws6rpyj0y9iadjg1890dwnnbjfdbzxsv6r48zbj7f8yn5y0cbl4";
      type = "gem";
    };
  };
}
