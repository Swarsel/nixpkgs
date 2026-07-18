{
  Ascii85 = {
    version = "2.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nmyxpngg5rycyryhq9l9hapz1y3iqyflskyksxkqm0832a5vjqm";
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

  afm = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ia5iw9xvvy1igaxsa08vvv4b5ry9ipyr18917pi8w0y4kvddm2v";
      type = "gem";
    };
  };

  asciidoctor = {
    version = "2.0.26";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hbin3j8wynl2fpqa3d6vb932pyngyfn8j2q6gbbn1n23z7srqqn";
      type = "gem";
    };
  };

  asciidoctor-pdf = {
    version = "2.3.24";

    dependencies = [
      "asciidoctor"
      "concurrent-ruby"
      "matrix"
      "prawn"
      "prawn-icon"
      "prawn-svg"
      "prawn-table"
      "prawn-templates"
      "treetop"
      "ttfunk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ldh43ps15dpnrgqaybyq2py9cn1m14q2z6djgg22fyl698yaxih";
      type = "gem";
    };
  };

  coderay = {
    version = "1.1.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
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

  css_parser = {
    version = "1.21.1";
    dependencies = [ "addressable" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1izp5vna86s7xivqzml4nviy01bv76arrd5is8wkncwp1by3zzbc";
      type = "gem";
    };
  };

  hashery = {
    version = "2.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qj8815bf7q6q7llm5rzdz279gzmpqmqqicxnzv066a020iwqffj";
      type = "gem";
    };
  };

  matrix = {
    version = "0.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nscas3a4mmrp1rc07cdjlbbpb2rydkindmbj3v3z5y1viyspmd0";
      type = "gem";
    };
  };

  pdf-core = {
    version = "0.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fz0yj4zrlii2j08kaw11j769s373ayz8jrdhxwwjzmm28pqndjg";
      type = "gem";
    };
  };

  pdf-reader = {
    version = "2.15.0";

    dependencies = [
      "Ascii85"
      "afm"
      "hashery"
      "ruby-rc4"
      "ttfunk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11h8dhhd2c8mxssibk9q6qn7ilj4p71crlfirw8pppn8pr85f0n5";
      type = "gem";
    };
  };

  polyglot = {
    version = "0.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bqnxwyip623d8pr29rg6m8r0hdg08fpr2yb74f46rn1wgsnxmjr";
      type = "gem";
    };
  };

  prawn = {
    version = "2.4.0";

    dependencies = [
      "pdf-core"
      "ttfunk"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g9avv2rprsjisdk137s9ljr05r7ajhm78hxa1vjsv0jyx22f1l2";
      type = "gem";
    };
  };

  prawn-icon = {
    version = "3.0.0";
    dependencies = [ "prawn" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xdnjik5zinnkjavmybbh2s52wzcpb8hzaqckiv0mxp0vs0x9j6s";
      type = "gem";
    };
  };

  prawn-svg = {
    version = "0.34.2";

    dependencies = [
      "css_parser"
      "matrix"
      "prawn"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "143sfwadbdrgi57am8ikalryjijdyl82h2sdc1cns3wl6b9pkzxg";
      type = "gem";
    };
  };

  prawn-table = {
    version = "0.2.2";
    dependencies = [ "prawn" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nxd6qmxqwl850icp18wjh5k0s3amxcajdrkjyzpfgq0kvilcv9k";
      type = "gem";
    };
  };

  prawn-templates = {
    version = "0.1.2";

    dependencies = [
      "pdf-reader"
      "prawn"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w9irn3rllm992c6j7fsx81gg539i7yy8zfddyw7q53hnlys0yhi";
      type = "gem";
    };
  };

  public_suffix = {
    version = "6.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1543ap9w3ydhx39ljcd675cdz9cr948x9mp00ab8qvq6118wv9xz";
      type = "gem";
    };
  };

  "pygments.rb" = {
    version = "4.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mzfxkzvgyrj9g6471mxa6d1jy59fsds9mfkx1balpng50xb12zl";
      type = "gem";
    };
  };

  rexml = {
    version = "3.4.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hninnbvqd2pn40h863lbrn9p11gvdxp928izkag5ysx8b1s5q0r";
      type = "gem";
    };
  };

  rouge = {
    version = "4.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pkp5icgm7s10b2n6b2pzbdsfiv0l5sxqyizx55qdmlpaxnk8xah";
      type = "gem";
    };
  };

  ruby-rc4 = {
    version = "0.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00vci475258mmbvsdqkmqadlwn6gj9m01sp7b5a3zd90knil1k00";
      type = "gem";
    };
  };

  tilt = {
    version = "2.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w27v04d7rnxjr3f65w1m7xyvr6ch6szjj2v5wv1wz6z5ax9pa9m";
      type = "gem";
    };
  };

  treetop = {
    version = "1.6.18";
    dependencies = [ "polyglot" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nl3q5ai7ikaa5sjdbspfa4njbrdvf7898zkplmalln6y4r3y153";
      type = "gem";
    };
  };

  ttfunk = {
    version = "1.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15iaxz9iak5643bq2bc0jkbjv8w2zn649lxgvh5wg48q9d4blw13";
      type = "gem";
    };
  };
}
