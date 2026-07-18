{
  addressable = {
    version = "2.8.10";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "031lb8jq55dxb5qiknzffl7nniqfmrc4603ggxqipnxywwp5ca6a";
      type = "gem";
    };
  };

  ast = {
    version = "2.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10yknjyn0728gjn6b5syynvrvrwm66bhssbxq8mkhshxghaiailm";
      type = "gem";
    };
  };

  aws-eventstream = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fqqdqg15rgwgz3mn4pj91agd20csk9gbrhi103d20328dfghsqi";
      type = "gem";
    };
  };

  aws-partitions = {
    version = "1.1241.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gkc08r1s7mvinl7301rahylj3z7myypdbkpvj5jwy72bm1zq3nd";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.246.0";

    dependencies = [
      "aws-eventstream"
      "aws-partitions"
      "aws-sigv4"
      "base64"
      "bigdecimal"
      "jmespath"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k6xqkipjli9vl40d4wqxcl7035lav9f9hnczilhwmj8i7n68f1r";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.123.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "080zh4g1lcjl0bz2l0gjm8vmpd60cvi0p658bh235ypqh9zg61fl";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.220.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z4cl87lbyw9qgp1l52sbjnysw63zmxih9wfhjfdvv67d9gdlzr3";
      type = "gem";
    };
  };

  aws-sdk-secretsmanager = {
    version = "1.129.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m69f1jghxlixd4b5wb2dsp38dly7nxm5si1klnajv89m23mqi00";
      type = "gem";
    };
  };

  aws-sigv4 = {
    version = "1.12.1";
    dependencies = [ "aws-eventstream" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "003ch8qzh3mppsxch83ns0jra8d222ahxs96p9cdrl0grfazywv9";
      type = "gem";
    };
  };

  base64 = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
  };

  bcrypt_pbkdf = {
    version = "1.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xjcp484qc4j4z42b087npgj50sd6yixchznp4z9p1k6rqilqhf2";
      type = "gem";
    };
  };

  benchmark = {
    version = "0.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v1337j39w1z7x9zs4q7ag0nfv4vs4xlsjx2la0wpv8s6hig2pa6";
      type = "gem";
    };
  };

  bigdecimal = {
    version = "4.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g9zi8c4i7g8zz0c3hxrw6mblrjvgn7akys60clb9si7c1k1gljk";
      type = "gem";
    };
  };

  builder = {
    version = "3.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      type = "gem";
    };
  };

  chef = {
    version = "19.2.12";

    dependencies = [
      "addressable"
      "aws-sdk-s3"
      "aws-sdk-secretsmanager"
      "bcrypt_pbkdf"
      "chef-config"
      "chef-licensing"
      "chef-utils"
      "chef-vault"
      "chef-zero"
      "corefoundation"
      "csv"
      "diff-lcs"
      "ed25519"
      "erubis"
      "ffi"
      "ffi-libarchive"
      "ffi-yajl"
      "iniparse"
      "inspec-core"
      "license-acceptance"
      "mixlib-archive"
      "mixlib-authentication"
      "mixlib-cli"
      "mixlib-log"
      "mixlib-shellout"
      "net-ftp"
      "net-sftp"
      "ohai"
      "plist"
      "proxifier2"
      "syslog"
      "syslog-logger"
      "train-core"
      "train-rest"
      "train-winrm"
      "unf_ext"
      "uri"
      "vault"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1iqg9vk9h40szvn1y5z1n1xs02l5n2bw5sahas2mx5ira2rs09d4";
      type = "gem";
    };
  };

  chef-cli = {
    version = "6.1.29";

    dependencies = [
      "addressable"
      "chef"
      "chef-licensing"
      "cookbook-omnifetch"
      "diff-lcs"
      "ffi-yajl"
      "license-acceptance"
      "minitar"
      "mixlib-cli"
      "mixlib-shellout"
      "pastel"
      "solve"
      "syslog"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x3n57wb0zxqij8gccp4ss34i3w2xnh3qqzf6cqgav806sb5pyrz";
      type = "gem";
    };
  };

  chef-config = {
    version = "19.2.12";

    dependencies = [
      "addressable"
      "chef-utils"
      "fuzzyurl"
      "mixlib-config"
      "mixlib-shellout"
      "racc"
      "tomlrb"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0999pzgsypcy5wvr42p3iagl4c96glcwfk08vlpxrc05q4jqwf24";
      type = "gem";
    };
  };

  chef-gyoku = {
    version = "1.5.0";

    dependencies = [
      "builder"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dpqrxpn5xx0jahga8kny2vagx7vxiinw4xcz6xwjg14z37s6m3k";
      type = "gem";
    };
  };

  chef-licensing = {
    version = "1.4.1";

    dependencies = [
      "chef-config"
      "faraday"
      "faraday-http-cache"
      "mixlib-log"
      "ostruct"
      "pstore"
      "tty-prompt"
      "tty-spinner"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0snnw3b3h0fydbllkgfc6gv724rlg7pv8lr9q84c972aibdsxs7h";
      type = "gem";
    };
  };

  chef-telemetry = {
    version = "1.1.1";

    dependencies = [
      "chef-config"
      "concurrent-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l9icc3nfdj28mip85vf31v5l60qsfqq3a5dscv7jryh1k94y05x";
      type = "gem";
    };
  };

  chef-utils = {
    version = "19.2.12";
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17jkln8gnxymvppnsbhzjza4gbhwc52shhql3yl1cn5c0lpsf0hb";
      type = "gem";
    };
  };

  chef-vault = {
    version = "4.2.9";
    dependencies = [ "syslog" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jv3mn4z650a8jbncyvz0sfb7kgwlz4rwhxw6k0f7q8m49p6mw7z";
      type = "gem";
    };
  };

  chef-winrm = {
    version = "2.5.0";

    dependencies = [
      "builder"
      "chef-gyoku"
      "erubi"
      "gssapi"
      "httpclient"
      "logging"
      "nori"
      "rexml"
      "rubyntlm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ww5iclrsl1fpzj7lm6ds5dza7ifn7px0a6wic787mrr5v3ly8fh";
      type = "gem";
    };
  };

  chef-winrm-elevated = {
    version = "1.2.5";

    dependencies = [
      "chef-winrm"
      "chef-winrm-fs"
      "erubi"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01sqzw2vdjkvg2wznb6mwzkfjpkplllymfz4p4fvxgsv3vmv91cr";
      type = "gem";
    };
  };

  chef-winrm-fs = {
    version = "1.4.2";

    dependencies = [
      "benchmark"
      "chef-winrm"
      "csv"
      "erubi"
      "logging"
      "rubyzip"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fk8p20cgz392h03l6nilk8wpwwwkx3819c8svy0q1zbz3x9dmp8";
      type = "gem";
    };
  };

  chef-zero = {
    version = "15.1.0";

    dependencies = [
      "ffi-yajl"
      "hashie"
      "mixlib-log"
      "rack"
      "rackup"
      "unf_ext"
      "uuidtools"
      "webrick"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12jqa1a1px56j5qkrl0bjb14pg7hyylbl23zd780rvmq7nghw8l5";
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
    version = "1.3.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aymcakhzl83k77g2f2krz07bg1cbafbcd2ghvwr4lky3rz86mkb";
      type = "gem";
    };
  };

  cookbook-omnifetch = {
    version = "0.12.2";
    dependencies = [ "mixlib-archive" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gqh66p6fxg438qpvc67s0y7ji9mvan6layyd7w9ljwva1snvy2n";
      type = "gem";
    };
  };

  cookstyle = {
    version = "8.6.10";
    dependencies = [ "rubocop" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mxznj53rlcg9bcycf5i6jximl1b5mdhm4x0k0wfb8xa79zz57cv";
      type = "gem";
    };
  };

  corefoundation = {
    version = "0.3.13";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14rgy3d636l9zy7zmw04j7pjkf3bn41vx7kb265l4zhxrik7gh19";
      type = "gem";
    };
  };

  csv = {
    version = "3.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gz7r2kazwwwyrwi95hbnhy54kwkfac5swh2gy5p5vw36fn38lbf";
      type = "gem";
    };
  };

  date = {
    version = "3.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h0db8r2v5llxdbzkzyllkfniqw9gm092qn7cbaib73v9lw0c3bm";
      type = "gem";
    };
  };

  diff-lcs = {
    version = "1.6.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qlrj2qyysc9avzlr4zs1py3x684hqm61n4czrsk1pyllz5x5q4s";
      type = "gem";
    };
  };

  domain_name = {
    version = "0.6.20240107";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cyr2xm576gqhqicsyqnhanni47408w2pgvrfi8pd13h2li3nsaz";
      type = "gem";
    };
  };

  ed25519 = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01n5rbyws1ijwc5dw7s88xx3zzacxx9k97qn8x11b6k8k18pzs8n";
      type = "gem";
    };
  };

  erubi = {
    version = "1.13.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1naaxsqkv5b3vklab5sbb9sdpszrjzlfsbqpy7ncbnw510xi10m0";
      type = "gem";
    };
  };

  erubis = {
    version = "2.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
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
    version = "0.5.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b8hgpci3wjm3rm41bzpasvsc5j253ljyg5rsajl62dkjk497pjw";
      type = "gem";
    };
  };

  faraday-http-cache = {
    version = "2.7.0";
    dependencies = [ "faraday" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "128dkxqssnnz801z86ykpaq4sv7pnac5yrgngbm951f0wsxw8ynd";
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
    version = "1.17.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kqasqvy8d7r09ri4n6bkdwbk63j7afd9ilsw34nzlgh0qp69ldw";
      type = "gem";
    };
  };

  ffi-libarchive = {
    version = "1.1.14";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19hnz16hmzzqsrrl29iw8v8lhvb8295c3z04mmadfjpfhjacmr53";
      type = "gem";
    };
  };

  ffi-yajl = {
    version = "2.7.7";

    dependencies = [
      "libyajl2"
      "yajl"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04m8c2bp7hgw2b1zrwanalkh1s2smyv2nl84vw0dzsn0253pca06";
      type = "gem";
    };
  };

  fuzzyurl = {
    version = "0.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03qchs33vfwbsv5awxg3acfmlcrf5xbhnbrc83fdpamwya0glbjl";
      type = "gem";
    };
  };

  gssapi = {
    version = "1.3.1";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qdfhj12aq8v0y961v4xv96a1y2z80h3xhvzrs9vsfgf884g6765";
      type = "gem";
    };
  };

  hashie = {
    version = "5.1.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w1qrab701d3a63aj2qavwc2fpcqmkzzh1w2x93c88zkjqc4frn2";
      type = "gem";
    };
  };

  http-accept = {
    version = "1.7.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09m1facypsdjynfwrcv19xcb1mqg8z6kk31g8r33pfxzh838c9n6";
      type = "gem";
    };
  };

  http-cookie = {
    version = "1.1.6";
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aga7z4p0dka4zcqw9i05wa4ab1q7h7cgnj328ldqqfycjz84jxs";
      type = "gem";
    };
  };

  httpclient = {
    version = "2.9.0";
    dependencies = [ "mutex_m" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j4qwj1nv66v3n9s4xqf64x2galvjm630bwa5xngicllwic5jr2b";
      type = "gem";
    };
  };

  iniparse = {
    version = "1.5.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wb1qy4i2xrrd92dc34pi7q7ibrjpapzk9y465v0n9caiplnb89n";
      type = "gem";
    };
  };

  inspec-core = {
    version = "7.0.107";

    dependencies = [
      "addressable"
      "chef-licensing"
      "chef-telemetry"
      "cookstyle"
      "csv"
      "faraday"
      "faraday-follow_redirects"
      "hashie"
      "license-acceptance"
      "method_source"
      "mixlib-log"
      "multipart-post"
      "ostruct"
      "parallel"
      "parslet"
      "pry"
      "rspec"
      "rspec-its"
      "rubyzip"
      "semverse"
      "sslshake"
      "syslog"
      "thor"
      "tomlrb"
      "train-core"
      "tty-prompt"
      "tty-table"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wjb8ap6z5nvsqlch7bx66p620rh2skxz4niawizff1y9zcfa23x";
      type = "gem";
    };
  };

  io-console = {
    version = "0.8.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
      type = "gem";
    };
  };

  ipaddress = {
    version = "0.8.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x86s0s11w202j6ka40jbmywkrx8fhq8xiy8mwvnkhllj57hqr45";
      type = "gem";
    };
  };

  jmespath = {
    version = "1.6.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cdw9vw2qly7q7r41s7phnac264rbsdqgj4l0h4nqgbjb157g393";
      type = "gem";
    };
  };

  json = {
    version = "2.19.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b1rabz30grash5wh0lcv109w2ggggmmbclwnajqrcdk7wrps2k7";
      type = "gem";
    };
  };

  language_server-protocol = {
    version = "3.17.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0311vah76kg5m6zr7wmkwyk5p2f9d9hyckjpn3xgr83ajkj7px";
      type = "gem";
    };
  };

  libyajl2 = {
    version = "2.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vx0mv0bbcy0qh3ik08b42vrq4kw1zg51121r18c0vvp4p3zcpda";
      type = "gem";
    };
  };

  license-acceptance = {
    version = "2.1.13";

    dependencies = [
      "pastel"
      "tomlrb"
      "tty-box"
      "tty-prompt"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12h5a3j57h50xkfpdz9gr42k0v8g1qxn2pnj5hbbzbmdhydjbjzf";
      type = "gem";
    };
  };

  lint_roller = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
  };

  little-plugger = {
    version = "1.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1frilv82dyxnlg8k1jhrvyd73l6k17mxc5vwxx080r4x1p04gwym";
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

  logging = {
    version = "2.4.0";

    dependencies = [
      "little-plugger"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jqcq2yxh973f3aw63nd3wxhqyhkncz3pf8v2gs3df0iqair725s";
      type = "gem";
    };
  };

  method_source = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1igmc3sq9ay90f8xjvfnswd1dybj1s3fi0dwd53inwsvqk4h24qq";
      type = "gem";
    };
  };

  mime-types = {
    version = "3.7.0";

    dependencies = [
      "logger"
      "mime-types-data"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mjyxl7c0xzyqdqa8r45hqg7jcw2prp3hkp39mdf223g4hfgdsyw";
      type = "gem";
    };
  };

  mime-types-data = {
    version = "3.2026.0414";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k28j6ww8rf43r5i8278jvm2cq3pnzsvqm7yqpb4p93kadjlq726";
      type = "gem";
    };
  };

  minitar = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gm2ksf678gr5cqr4a3mzx0zvwrc7z2qvkfd8rwh209qdzxhrnrq";
      type = "gem";
    };
  };

  mixlib-archive = {
    version = "1.3.3";
    dependencies = [ "mixlib-log" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mkhk1wz2skjijacygdak81i41syp9bwdi9kasij22p6bqjyqrhy";
      type = "gem";
    };
  };

  mixlib-authentication = {
    version = "3.0.10";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07m6q8icjjzrv7k2vsjqmviswqv6cigc577hf48liy7b1i4l9gn5";
      type = "gem";
    };
  };

  mixlib-cli = {
    version = "2.1.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ydxlfgd7nnj3rp1y70k4yk96xz5cywldjii2zbnw3sq9pippwp6";
      type = "gem";
    };
  };

  mixlib-config = {
    version = "3.0.27";
    dependencies = [ "tomlrb" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j0122lv2qgccl61njqi0pj6sp6nb85y07gcmw16bwg4k0c8nx6p";
      type = "gem";
    };
  };

  mixlib-log = {
    version = "3.2.3";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s57cq8qx3823pcfzizshp8vagvp3f87r0lksknj18r26nl3y79a";
      type = "gem";
    };
  };

  mixlib-shellout = {
    version = "3.3.9";
    dependencies = [ "chef-utils" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "126k9zgxwj726gi0q0ywj4kdzf1gfm8z16i1nn7dw9kmn3imxpqf";
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

  multi_json = {
    version = "1.20.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vfaab23d85617ps412ydb8ap4ci1sfzi8ainn8yyifc0pl38f9g";
      type = "gem";
    };
  };

  multipart-post = {
    version = "2.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a5lrlvmg2kb2dhw3lxcsv6x276bwgsxpnka1752082miqxd0wlq";
      type = "gem";
    };
  };

  mutex_m = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l875dw0lk7b2ywa54l0wjcggs94vb7gs8khfw9li75n2sn09jyg";
      type = "gem";
    };
  };

  net-ftp = {
    version = "0.3.9";

    dependencies = [
      "net-protocol"
      "time"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r9vn7q6c66y4iw048qdbqviv7bankdkcziz12fzfa7lyz61fy1h";
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

  net-protocol = {
    version = "0.2.2";
    dependencies = [ "timeout" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a32l4x73hz200cm587bc29q8q9az278syw3x6fkc9d1lv5y0wxa";
      type = "gem";
    };
  };

  net-scp = {
    version = "4.1.0";
    dependencies = [ "net-ssh" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p8s7l4pr6hkn0l6rxflsc11alwi1kfg5ysgvsq61lz5l690p6x9";
      type = "gem";
    };
  };

  net-sftp = {
    version = "4.0.0";
    dependencies = [ "net-ssh" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r33aa2d61hv1psm0l0mm6ik3ycsnq8symv7h84kpyf2b7493fv5";
      type = "gem";
    };
  };

  net-ssh = {
    version = "7.3.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1m1d6rs40rjvdb6df34fi3za1c2ajdiydv4jzpjj03iq7hhrw0k5";
      type = "gem";
    };
  };

  netrc = {
    version = "0.11.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
  };

  nori = {
    version = "2.7.1";
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qb84bbi74q0zgs09sdkq750jf2ri3lblbry0xi4g1ard4rwsrk1";
      type = "gem";
    };
  };

  ohai = {
    version = "19.1.24";

    dependencies = [
      "base64"
      "chef-config"
      "chef-utils"
      "ffi"
      "ffi-yajl"
      "ipaddress"
      "mixlib-cli"
      "mixlib-config"
      "mixlib-log"
      "mixlib-shellout"
      "plist"
      "train-core"
      "wmi-lite"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n3prpm36kxxk0jx8qs90gj72382jw7az9rnqnaa88c35793ypx1";
      type = "gem";
    };
  };

  ostruct = {
    version = "0.6.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04nrir9wdpc4izqwqbysxyly8y7hsfr4fsv69rw91lfi9d5fv8lm";
      type = "gem";
    };
  };

  parallel = {
    version = "1.28.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0w697335hi5dk5ay9kyn53399sy87y8v0y6ij93m5wmshhadxrik";
      type = "gem";
    };
  };

  parser = {
    version = "3.3.11.1";

    dependencies = [
      "ast"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m2xqvn1la62hji1mn04y59giikww95p2hs0r4y2rrz3mdxcwyni";
      type = "gem";
    };
  };

  parslet = {
    version = "2.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01pnw6ymz6nynklqvqxs4bcai25kcvnd5x4id9z3vd1rbmlk0lfl";
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

  plist = {
    version = "3.7.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hlaf4b3d8grxm9fqbnam5gwd55wvghl0jyzjd1hc5hirhklaynk";
      type = "gem";
    };
  };

  prism = {
    version = "1.9.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
  };

  proxifier2 = {
    version = "1.1.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cmk01qdk3naa86grjd5arf6xxy9axf5y6a0sqm7zis9lr4d43h3";
      type = "gem";
    };
  };

  pry = {
    version = "0.16.0";

    dependencies = [
      "coderay"
      "method_source"
      "reline"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kh5nv8v74k1ccy6gc7nd04aaf1cjkbk7g8pwy2izvcqaq36jv6p";
      type = "gem";
    };
  };

  pstore = {
    version = "0.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11mvc9s72fq7bl6h3f1rcng4ffa0nbjy1fr9wpshgzn4b9zznxm2";
      type = "gem";
    };
  };

  public_suffix = {
    version = "7.0.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08znfv30pxmdkjyihvbjqbvv874dj3nybmmyscl958dy3f7v12qs";
      type = "gem";
    };
  };

  racc = {
    version = "1.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
  };

  rack = {
    version = "3.2.6";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hhjy9gcp52dzij05gmidqac8g28ski5xm67prwmdqmjfcgqxmsy";
      type = "gem";
    };
  };

  rackup = {
    version = "2.3.1";
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s48d2a0z5f0cg4npvzznf933vipi6j7gmk16yc913kpadkw4ybc";
      type = "gem";
    };
  };

  rainbow = {
    version = "3.1.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
  };

  regexp_parser = {
    version = "2.12.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fwfw26a32rps78920nn29shqg2zmqv72i89j1fap41isshida9m";
      type = "gem";
    };
  };

  reline = {
    version = "0.6.3";
    dependencies = [ "io-console" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
  };

  rest-client = {
    version = "2.1.0";

    dependencies = [
      "http-accept"
      "http-cookie"
      "mime-types"
      "netrc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs74yzl58agzx9dgjhcpgmzfn61fqkk33k1js2y5yhlvc5l19im";
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

  rspec = {
    version = "3.13.2";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11q5hagj6vr694innqj4r45jrm8qcwvkxjnphqgyd66piah88qi0";
      type = "gem";
    };
  };

  rspec-core = {
    version = "3.13.6";
    dependencies = [ "rspec-support" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bcbh9yv6cs6pv299zs4bvalr8yxa51kcdd1pjl60yv625j3r0m8";
      type = "gem";
    };
  };

  rspec-expectations = {
    version = "3.13.5";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl8npj0jfpy31bxi6syc7jymyd861q277sfr6jawq2hv6hx791k";
      type = "gem";
    };
  };

  rspec-its = {
    version = "2.0.0";

    dependencies = [
      "rspec-core"
      "rspec-expectations"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pv0a8pvixgrwsi6j4nlpyn9m0jw9zn92dakjdg87wj9h71qp3m8";
      type = "gem";
    };
  };

  rspec-mocks = {
    version = "3.13.8";

    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iqxmw0knjiz5nf6pgr8ihs6cjzh89f0ppj3fqiz8cvms79x6sh8";
      type = "gem";
    };
  };

  rspec-support = {
    version = "3.13.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z64h5rznm2zv21vjdjshz4v0h7bxvg02yc6g7yzxakj11byah06";
      type = "gem";
    };
  };

  rubocop = {
    version = "1.84.2";

    dependencies = [
      "json"
      "language_server-protocol"
      "lint_roller"
      "parallel"
      "parser"
      "rainbow"
      "regexp_parser"
      "rubocop-ast"
      "ruby-progressbar"
      "unicode-display_width"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pxzipl8a1bv62jdfykh7j4ymdr4aiffjvwsny6drwv886jwx4jn";
      type = "gem";
    };
  };

  rubocop-ast = {
    version = "1.49.1";

    dependencies = [
      "parser"
      "prism"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dahfpnzz63hyqxa03x8rypnrxzwyvh4i5a8ri34bzpnf3pg64j4";
      type = "gem";
    };
  };

  ruby-progressbar = {
    version = "1.13.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
  };

  rubyntlm = {
    version = "0.6.5";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x8l0d1v88m40mby4jvgal46137cv8gga2lk7zlrxqlsp41380a7";
      type = "gem";
    };
  };

  rubyzip = {
    version = "2.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05an0wz87vkmqwcwyh5rjiaavydfn5f4q1lixcsqkphzvj7chxw5";
      type = "gem";
    };
  };

  semverse = {
    version = "3.0.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vrh6p0756n3gjnk6am1cc4kmw6wzzd02hcajj27rlsqg3p6lwn9";
      type = "gem";
    };
  };

  socksify = {
    version = "1.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mm8m7zfvszbf9l750c2x693p8100rrk6ckvcp6909631ir02ang";
      type = "gem";
    };
  };

  solve = {
    version = "4.0.4";

    dependencies = [
      "molinillo"
      "semverse"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "059lrsf40rl5kclp1w8pb0fzz5sv8aikg073cwcvn5mndk14ayky";
      type = "gem";
    };
  };

  sslshake = {
    version = "1.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0r3ifksx8a05yqhv7nc4cwan8bwmxgq5kyv7q7hy2h9lv5zcjs8h";
      type = "gem";
    };
  };

  strings = {
    version = "0.2.1";

    dependencies = [
      "strings-ansi"
      "unicode-display_width"
      "unicode_utils"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yynb0qhhhplmpzavfrrlwdnd1rh7rkwzcs4xf0mpy2wr6rr6clk";
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

  syslog = {
    version = "0.4.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wklh86rhpiff34ja0hda5pwdfywybjvb50hqhz90wpyhblqmhy4";
      type = "gem";
    };
  };

  syslog-logger = {
    version = "1.6.8";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14y20phq1khdla4z9wvf98k7j3x6n0rjgs4f7vb0xlf7h53g6hbm";
      type = "gem";
    };
  };

  thor = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gcarlmpfbmqnjvwfz44gdjhcmm634di7plcx2zdgwdhrhifhqw7";
      type = "gem";
    };
  };

  time = {
    version = "0.4.2";
    dependencies = [ "date" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1arxpii25xgb3fkgqp5acyc0x6179j3qzld78lflgsdxqfcf897k";
      type = "gem";
    };
  };

  timeout = {
    version = "0.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jxcji88mh6xsqz0mfzwnxczpg7cyniph7wpavnavfz7lxl77xbq";
      type = "gem";
    };
  };

  tomlrb = {
    version = "1.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00x5y9h4fbvrv4xrjk4cqlkm4vq8gv73ax4alj3ac2x77zsnnrk8";
      type = "gem";
    };
  };

  train-core = {
    version = "3.16.2";

    dependencies = [
      "addressable"
      "ffi"
      "json"
      "mixlib-shellout"
      "net-scp"
      "net-ssh"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vz9ylinr4fbca7ab7ipv57hxd988a13b0vlwrhlxhckdaf215cg";
      type = "gem";
    };
  };

  train-rest = {
    version = "0.5.0";

    dependencies = [
      "aws-sigv4"
      "rest-client"
      "train-core"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qwa4vwzz9lipvibd83ra6lb7a345xxyg8r13z7p0982jsrspp33";
      type = "gem";
    };
  };

  train-winrm = {
    version = "0.4.3";

    dependencies = [
      "chef-winrm"
      "chef-winrm-elevated"
      "chef-winrm-fs"
      "socksify"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yl4hzwksa89xd7hzfhr299q1w8hqmvzcfqxxi7rhm22y9k5d8sg";
      type = "gem";
    };
  };

  tty-box = {
    version = "0.7.0";

    dependencies = [
      "pastel"
      "strings"
      "tty-cursor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12yzhl3s165fl8pkfln6mi6mfy3vg7p63r3dvcgqfhyzq6h57x0p";
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

  tty-table = {
    version = "0.12.0";

    dependencies = [
      "pastel"
      "strings"
      "tty-screen"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fcrbfb0hjd9vkkazkksri93dv9wgs2hp6p1xwb1lp43a13pmhpx";
      type = "gem";
    };
  };

  unf_ext = {
    version = "0.0.9.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sf6bxvf6x8gihv6j63iakixmdddgls58cpxpg32chckb2l18qcj";
      type = "gem";
    };
  };

  unicode-display_width = {
    version = "2.6.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nkz7fadlrdbkf37m0x7sw8bnz8r355q3vwcfb9f9md6pds9h9qj";
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
    version = "1.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jrl2vkdvc5aq8q3qvjmmrgjxfm784w8h7fal19qg7q7gh9msj1l";
      type = "gem";
    };
  };

  uuidtools = {
    version = "2.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s8h35ia80p919kidb66nfp8904rhdmn41z9ghsx4ihp2ild3bn4";
      type = "gem";
    };
  };

  vault = {
    version = "0.18.2";
    dependencies = [ "aws-sigv4" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z6j8s8cdmkbwzfis3dpk5dm91zi5fasids8npzrxhb4hcnnqd19";
      type = "gem";
    };
  };

  webrick = {
    version = "1.9.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ca1hr2rxrfw7s613rp4r4bxb454i3ylzniv9b9gxpklqigs3d5y";
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

  wmi-lite = {
    version = "1.0.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nnx4xz8g40dpi3ccqk5blj1ck06ydx09f9diksn1ghd8yxzavhi";
      type = "gem";
    };
  };

  yajl = {
    version = "0.3.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1r1i0jjxbnnll8336y144sphn1cdns5n8ygb31z826i6xirq8w8d";
      type = "gem";
    };
  };
}
