{
  addressable = {
    version = "2.9.0";
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1by7h2lwziiblizpd5yx87jsq8ppdhzvwf08ga34wzqgcv1nmpvz";
      type = "gem";
    };
  };

  async = {
    version = "2.42.0";

    dependencies = [
      "console"
      "fiber-annotation"
      "io-event"
      "metrics"
      "traces"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ik5p6pgx01mrg2c5pj6rmjwr2s5sbvip84zcysxb5cc7clphq2k";
      type = "gem";
    };
  };

  async-http = {
    version = "0.95.1";

    dependencies = [
      "async"
      "async-pool"
      "io-endpoint"
      "io-stream"
      "metrics"
      "protocol-http"
      "protocol-http1"
      "protocol-http2"
      "protocol-url"
      "traces"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v3q2kn9j5vfag7b4zv2vc1i4jkrqjz1pc109df6vh04q9cd8g8c";
      type = "gem";
    };
  };

  async-pool = {
    version = "0.11.2";
    dependencies = [ "async" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vg3lwb3yhq0rad3dm00vp35vrahkbxgl4kx3d2rqkdh09xs2hqa";
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
    version = "1.1267.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07i2n8f7cpbcckj6zqlivhw05khsrg77bijj2jdb00y3z2zcd90m";
      type = "gem";
    };
  };

  aws-sdk-cloudwatchlogs = {
    version = "1.159.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ja3j4a3mvgcdrcpzisip40h5f4mix0724p14w8c1phxd794xz5r";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.254.0";

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
      sha256 = "1zhj444iybzs1ikw1p4arv3zayw9xkk1ifnsb6g3r2j6p0h34gpf";
      type = "gem";
    };
  };

  aws-sdk-firehose = {
    version = "1.112.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sxr068m9fxw04m79ainsr3fniq7pxdwcp9syxbxxyq65bgq300g";
      type = "gem";
    };
  };

  aws-sdk-kinesis = {
    version = "1.103.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g7m6ii4m03h6prd21z42yll259qlk08agfydkcikrixq1nlf3rz";
      type = "gem";
    };
  };

  aws-sdk-kms = {
    version = "1.130.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jfpgjyhq3f7w67p3361f1racrc1m502zan934m7mdrir9i3ds52";
      type = "gem";
    };
  };

  aws-sdk-s3 = {
    version = "1.227.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sdk-kms"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fd9xq7xyadlldgd9l9iry3fi38wwr1iaag9ax4xpirpkazj6asm";
      type = "gem";
    };
  };

  aws-sdk-sqs = {
    version = "1.117.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wj489w3v5canns7c5lnp38hjf954gxfvlva76vwrw9618cvzznd";
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

  bson = {
    version = "4.15.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19vgs9rzzyvd7jfrzynjnc6518q0ffpfciyicfywbp77zl8nc9hk";
      type = "gem";
    };
  };

  concurrent-ruby = {
    version = "1.3.7";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c2i64xsd35vijnb50rxb70g508s0x674xi0qpyyb8jy7bncl4j4";
      type = "gem";
    };
  };

  console = {
    version = "1.36.0";

    dependencies = [
      "fiber-annotation"
      "fiber-local"
      "json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01vg83f2q7n0q5dsq2sfjmm6mrizhyzkmw21i4ysg06g0slrwna5";
      type = "gem";
    };
  };

  "cool.io" = {
    version = "1.9.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lzay9zxgf7j2avpl19334si092f3xyfd819wq75nmbrdwp4l0m5";
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

  digest-crc = {
    version = "0.7.0";
    dependencies = [ "rake" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01wcsyhaadss4zzvqh12kvbq3hmkl5y4fck7pr608hd24qxc5bb4";
      type = "gem";
    };
  };

  drb = {
    version = "2.2.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wrkl7yiix268s2md1h6wh91311w95ikd8fy8m5gx589npyxc00b";
      type = "gem";
    };
  };

  elastic-transport = {
    version = "8.5.3";

    dependencies = [
      "faraday"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i2qzvf40hvp1s0m44kvpzi9zsinsy7w8fsrj62saa07n6pkdw1v";
      type = "gem";
    };
  };

  elasticsearch = {
    version = "9.4.3";

    dependencies = [
      "elastic-transport"
      "elasticsearch-api"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hpvj11mbn74z8ph17qjs1n7jkpjv5csr1x1nhrnk9zi04xnwjnw";
      type = "gem";
    };
  };

  elasticsearch-api = {
    version = "9.4.3";

    dependencies = [
      "base64"
      "multi_json"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14n9mypalmi9f1gv9xkdirjxhihv3wiks2vsgdnl7q19wyfq2626";
      type = "gem";
    };
  };

  excon = {
    version = "1.5.0";
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l3dpg45i74ap1d7c4wyrdlc67l9vj4kgzv2l2r8mg1304fss0y5";
      type = "gem";
    };
  };

  faraday = {
    version = "2.14.3";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y7j6yzv07zggic6g0p2v1ivnvkzsbqjnfdl4215qqb6cxz290hq";
      type = "gem";
    };
  };

  faraday-excon = {
    version = "2.4.0";

    dependencies = [
      "excon"
      "faraday"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xn867jjsy4dj0sxrrwd58l3kpdjs1in4p1jcbmni126hcszy1ra";
      type = "gem";
    };
  };

  faraday-net_http = {
    version = "3.4.4";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "125m3qri52vwh5v9dhq0dkqxf8629cxrf99yyc01pva72wasyy0f";
      type = "gem";
    };
  };

  fiber-annotation = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00vcmynyvhny8n4p799rrhcx0m033hivy0s1gn30ix8rs7qsvgvs";
      type = "gem";
    };
  };

  fiber-local = {
    version = "1.1.0";
    dependencies = [ "fiber-storage" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
  };

  fiber-storage = {
    version = "1.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qa0j9qjwav9xb0n3isx0rbh0942xrfback392n6vs8bidnmp3pl";
      type = "gem";
    };
  };

  fluent-config-regexp-type = {
    version = "1.0.0";
    dependencies = [ "fluentd" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hk0vxcmlbid7n6piyv3x83j5gyiz7in397l9x3c6nh69wicy7gm";
      type = "gem";
    };
  };

  fluent-plugin-cloudwatch-logs = {
    version = "0.15.0";

    dependencies = [
      "aws-sdk-cloudwatchlogs"
      "fluentd"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d4vr7mkha72f65pnisqp26gppas0zhz4xvpyqk0ka9mkwyj2m2m";
      type = "gem";
    };
  };

  fluent-plugin-concat = {
    version = "2.6.2";
    dependencies = [ "fluentd" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18vsv1lh41hk12ji11zsf2ipqzw0l6isxw748yhrlzfz55lh2j99";
      type = "gem";
    };
  };

  fluent-plugin-elasticsearch = {
    version = "6.0.0";

    dependencies = [
      "elasticsearch"
      "excon"
      "faraday"
      "faraday-excon"
      "fluentd"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lnz56kaxqp28dckn5f7xb6mywf5dr0v56lvskx5jr67z97wsich";
      type = "gem";
    };
  };

  fluent-plugin-kafka = {
    version = "0.19.3";

    dependencies = [
      "fluentd"
      "ltsv"
      "ruby-kafka"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0p3z1z22ir442rrxv8f8ki50iv6hmx7q5zm0lglyfh6nmkpf6vv1";
      type = "gem";
    };
  };

  fluent-plugin-kinesis = {
    version = "3.7.0";

    dependencies = [
      "aws-sdk-firehose"
      "aws-sdk-kinesis"
      "fluentd"
      "google-protobuf"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jq7ci8h243g23dhx9vbqz1sb2kipz7v7y318wvj4lnq2xgpmmj5";
      type = "gem";
    };
  };

  fluent-plugin-mongo = {
    version = "1.6.3";

    dependencies = [
      "bigdecimal"
      "fluentd"
      "mongo"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09h70j007gb7ia66fm67b9842vbdfp18h1bf8mgjxvhz4ylx4p26";
      type = "gem";
    };
  };

  fluent-plugin-record-reformer = {
    version = "0.9.1";
    dependencies = [ "fluentd" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gwfrfyi9is4l9q4ih3c4l3c9qvyh00jnd2qajdpdh5xjj2m7akn";
      type = "gem";
    };
  };

  fluent-plugin-rewrite-tag-filter = {
    version = "2.4.0";

    dependencies = [
      "fluent-config-regexp-type"
      "fluentd"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vjvn8ph87cl2dl0dbaap69rciglsdma1y5ghn2vm5mvh5h7xbs6";
      type = "gem";
    };
  };

  fluent-plugin-s3 = {
    version = "1.8.5";

    dependencies = [
      "aws-sdk-s3"
      "aws-sdk-sqs"
      "fluentd"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1r6vqs2zlsck2v6pd89g9s2mxk064y0pls0s3awbq4186a8kpn9r";
      type = "gem";
    };
  };

  fluent-plugin-webhdfs = {
    version = "1.6.0";

    dependencies = [
      "fluentd"
      "webhdfs"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mqj7fk1ylydkrjrph2n15n6bcn1vpgnjh4z2svxi2qsc5rnaki3";
      type = "gem";
    };
  };

  fluentd = {
    version = "1.19.3";

    dependencies = [
      "async-http"
      "base64"
      "cool.io"
      "csv"
      "drb"
      "http_parser.rb"
      "logger"
      "msgpack"
      "net-http"
      "ostruct"
      "serverengine"
      "sigdump"
      "strptime"
      "tzinfo"
      "tzinfo-data"
      "uri"
      "webrick"
      "yajl-ruby"
      "zstd-ruby"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n2f3lfc99ry640i1j2xar2fp9yn6fhrbzdw0ilpdicrclnmb3y2";
      type = "gem";
    };
  };

  google-protobuf = {
    version = "4.35.1";

    dependencies = [
      "bigdecimal"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09ipzsijxkrgwnyic0l4yhnazw46ca7ll0adza6za66r649lg9m3";
      type = "gem";
    };
  };

  "http_parser.rb" = {
    version = "0.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yh924g697spcv4hfigyxgidhyy6a7b9007rnac57airbcadzs4s";
      type = "gem";
    };
  };

  io-endpoint = {
    version = "0.17.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0f1kzf4d5qgqgfjh52a8pf3pii5dmav6ib0zq4wmicqnq5kggsiz";
      type = "gem";
    };
  };

  io-event = {
    version = "1.19.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1rkfxcydk07qa9zs2ll7fj9zhl374v6vb0m9m7dbz74832isj6l5";
      type = "gem";
    };
  };

  io-stream = {
    version = "0.13.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pi0vr60l3ld4mlfrhgbiyvxkribi82258mlh1s7dg8gzd6pq3ap";
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
    version = "2.20.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ay31y1yl208xrpcsw6b0k4q309magq7q5prmdbb0lm9ampbqqlk";
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

  ltsv = {
    version = "0.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wrjvc5079zhpn62k1yflrf7js6vaysrg1qwggf7bj2zi0p5rhys";
      type = "gem";
    };
  };

  metrics = {
    version = "0.15.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wlh0g4xmfqa41dsh4m3514q3jcvy6jx97mwn6ayj62ir6xdbpk1";
      type = "gem";
    };
  };

  mongo = {
    version = "2.18.3";
    dependencies = [ "bson" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xinxrx25q9hzl78bhm404vlfgm04csbgkr7kkrw47s53l9mghhf";
      type = "gem";
    };
  };

  msgpack = {
    version = "1.8.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18g6ps30z6m365bly7sfialavnsf6m6qamdxsr84w96k51j4mnlb";
      type = "gem";
    };
  };

  multi_json = {
    version = "1.21.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1040lr5y2phn7avdyam6zw6ikprlmk77biw3yhclsfwfh0qnl4p6";
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

  protocol-hpack = {
    version = "1.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14ddqg5mcs9ysd1hdzkm5pwil0660vrxcxsn576s3387p0wa5v3g";
      type = "gem";
    };
  };

  protocol-http = {
    version = "0.62.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fvpza7nnbyd3nfxkn5gych6diwns386g2ib9s6azh99c3sz5hg1";
      type = "gem";
    };
  };

  protocol-http1 = {
    version = "0.39.0";
    dependencies = [ "protocol-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1syqgaklsn9rf11xmll2s3ms7jvpd5zjng9jdb3r8pbgv963z6z4";
      type = "gem";
    };
  };

  protocol-http2 = {
    version = "0.26.0";

    dependencies = [
      "protocol-hpack"
      "protocol-http"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11kl6768hpzgvvvlpyvmr74v0jqf2vslcwngs3643cl2h3brrj5s";
      type = "gem";
    };
  };

  protocol-url = {
    version = "0.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qd9vsn9sif58swfqsyj429aynqyv6hpgbzxqrd83baidcxw1m34";
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

  rake = {
    version = "13.4.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "009p524zl0p0kfa65nii8wdmaigkmawv9pbvlcffky7islmmp0nb";
      type = "gem";
    };
  };

  ruby-kafka = {
    version = "1.5.0";
    dependencies = [ "digest-crc" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13i3fvjy0n1n1aa71b30nwx2xchhsps3yhi17r0s6ay7wr26jr7p";
      type = "gem";
    };
  };

  serverengine = {
    version = "2.4.0";

    dependencies = [
      "base64"
      "logger"
      "sigdump"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g26sbxwidgryn57nzxw25dq67ij037vml9ld28ckyl7y4qs8hja";
      type = "gem";
    };
  };

  sigdump = {
    version = "0.2.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hkj8fsl1swjfqvzgrwbyrwwn7403q95fficbll8nibhrqf6qw5v";
      type = "gem";
    };
  };

  strptime = {
    version = "0.2.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ycs0xz58kymf7yp4h56f0nid2z7g3s18dj7pa3p790pfzzpgvcq";
      type = "gem";
    };
  };

  traces = {
    version = "0.18.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05722prvh34n96irnxa762wz0yj2nyrz70ab2zby3b6snjf69wc0";
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

  tzinfo-data = {
    version = "1.2026.3";
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ygpikd3hdqsi16gqh33r5al1b9xdwrv2wl3rw210g7iar9vr3s7";
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

  webhdfs = {
    version = "0.11.0";
    dependencies = [ "addressable" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "157b725w4795i4bk2318fbj4bg1r83kvnmnbjykgzypi94mfhc6i";
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

  yajl-ruby = {
    version = "1.4.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      type = "gem";
    };
  };

  zstd-ruby = {
    version = "1.5.7.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08gxd4hm9qpiyf9bvwwxba75g70j8vascj44y89xccps7bwgplfy";
      type = "gem";
    };
  };
}
