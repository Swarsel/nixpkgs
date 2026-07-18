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
    version = "1.1140.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1snwg6nj6v1rmqp96xlff3k1lkg0z4jamkj7cj978vdkzsfi807k";
      type = "gem";
    };
  };

  aws-sdk-core = {
    version = "3.228.0";

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
      sha256 = "0r3mvwqndqg0c29cnznhmgnkcsmxncx4r6gqwfjwp5imkrgarp86";
      type = "gem";
    };
  };

  aws-sdk-ec2 = {
    version = "1.544.0";

    dependencies = [
      "aws-sdk-core"
      "aws-sigv4"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wi5xy62z34r6h1j5padz00wi6q21v4g1i7b04sqnvmb9kxdklzf";
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
    version = "3.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1p2szbr4jdvmwaaj2kxlbv1rp0m6ycbgfyp0kjkkkswmniv5y21r";
      type = "gem";
    };
  };

  bindata = {
    version = "2.5.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n4ymlgik3xcg94h52dzmh583ss40rl3sn0kni63v56sq8g6l62k";
      type = "gem";
    };
  };

  bolt = {
    version = "4.0.0";

    dependencies = [
      "CFPropertyList"
      "addressable"
      "aws-sdk-ec2"
      "concurrent-ruby"
      "ffi"
      "hiera-eyaml"
      "jwt"
      "logging"
      "minitar"
      "net-scp"
      "net-ssh"
      "net-ssh-krb"
      "orchestrator_client"
      "puppet"
      "puppet-resource_api"
      "puppet-strings"
      "puppetfile-resolver"
      "r10k"
      "ruby_smb"
      "terminal-table"
      "winrm"
      "winrm-fs"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j7yr4v8id58ag521l1xmdqhb7nsmnffb7bv32krfzvwi1f26mrj";
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

  colored2 = {
    version = "3.1.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jlbqa9q4mvrm73aw9mxh23ygzbjiqwisl32d8szfb5fxvbjng5i";
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

  facter = {
    version = "4.10.0";

    dependencies = [
      "hocon"
      "thor"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17d561xf4s5016fm9jkfkkafn6660g04fz1yp5xfvkb0j4xj32mp";
      type = "gem";
    };
  };

  faraday = {
    version = "2.13.4";

    dependencies = [
      "faraday-net_http"
      "json"
      "logger"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09mcghancmn0s5cwk2xz581j3xm3xqxfv0yxg75axnyhrx9gy6f7";
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
    version = "3.4.1";
    dependencies = [ "net-http" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fxbckg468dabkkznv48ss8zv14d9cd8mh1rr3m98aw7wzx5fmq9";
      type = "gem";
    };
  };

  faraday-net_http_persistent = {
    version = "2.3.1";

    dependencies = [
      "faraday"
      "net-http-persistent"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18zwd0p2vknmpk7zrw3gz9rsln69is8h2g831yhhfy52sqvvmzr3";
      type = "gem";
    };
  };

  fast_gettext = {
    version = "2.4.0";
    dependencies = [ "prime" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gsz2ywvnms7b4w7bs4dg7cykhgx7z74fa7xy0sbw45a0v2c89px";
      type = "gem";
    };
  };

  ffi = {
    version = "1.17.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19kdyjg3kv7x0ad4xsd4swy5izsbb1vl1rpb6qqcqisr5s23awi9";
      type = "gem";
    };
  };

  forwardable = {
    version = "1.3.3";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1b5g1i3xdvmxxpq4qp0z4v78ivqnazz26w110fh4cvzsdayz8zgi";
      type = "gem";
    };
  };

  getoptlong = {
    version = "0.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198vy9dxyzibqdbw9jg8p2ljj9iknkyiqlyl229vz55rjxrz08zx";
      type = "gem";
    };
  };

  gettext = {
    version = "3.5.1";

    dependencies = [
      "erubi"
      "locale"
      "prime"
      "racc"
      "text"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aji3873pxn6gc5qkvnv5y9025mqk0p6h22yrpyz2b3yx9qpzv03";
      type = "gem";
    };
  };

  gettext-setup = {
    version = "1.1.0";

    dependencies = [
      "fast_gettext"
      "gettext"
      "locale"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v6liz934gmx1wv1z6bvpim6aanbr66xjhb90lc9z1jxayczmm1a";
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

  gyoku = {
    version = "1.4.0";

    dependencies = [
      "builder"
      "rexml"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kd2q59xpm39hpvmmvyi6g3f1fr05xjbnxwkrdqz4xy7hirqi79q";
      type = "gem";
    };
  };

  hiera-eyaml = {
    version = "3.4.0";

    dependencies = [
      "highline"
      "optimist"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m7zr33qfhvwxqx4kh61rabmbkhp3y4ans66kfpgrzjyvj1vdb6d";
      type = "gem";
    };
  };

  highline = {
    version = "3.1.2";
    dependencies = [ "reline" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jmvyhjp2v3iq47la7w6psrxbprnbnmzz0hxxski3vzn356x7jv7";
      type = "gem";
    };
  };

  hocon = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "106dmzsl1bxkqw5xaif012nwwfr3k9wff32cqc77ibjngknj6477";
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

  io-console = {
    version = "0.8.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jszj95hazqqpnrjjzr326nn1j32xmsc9xvd97mbcrrgdc54858y";
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
    version = "2.13.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s5vklcy2fgdxa9c6da34jbfrqq7xs6mryjglqqb5iilshcg3q82";
      type = "gem";
    };
  };

  jwt = {
    version = "2.10.2";
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x64l31nkqjwfv51s2vsm0yqq4cwzrlnji12wvaq761myx3fxq9i";
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

  locale = {
    version = "2.1.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "107pm4ccmla23z963kyjldgngfigvchnv85wr6m69viyxxrrjbsj";
      type = "gem";
    };
  };

  log4r = {
    version = "1.1.10";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ri90q0frfmigkirqv5ihyrj59xm8pq5zcmf156cbdv4r4l2jicv";
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
    version = "1.17.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06sabsvnw0x1aqdcswc6bqrqz6705548bfd8z22jxgxfjrn1yn3n";
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

  net-http = {
    version = "0.6.0";
    dependencies = [ "uri" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ysrwaabhf0sn24jrp0nnp51cdv0jf688mh5i6fsz63q2c6b48cn";
      type = "gem";
    };
  };

  net-http-persistent = {
    version = "4.0.6";
    dependencies = [ "connection_pool" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfxhhn1lqnxx8dj3ig3lgnhkxq5jsb0brg7w2wnrpwf8c23mfra";
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

  net-ssh = {
    version = "7.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w1ypxa3n6mskkwb00b489314km19l61p5h3bar6zr8cng27c80p";
      type = "gem";
    };
  };

  net-ssh-krb = {
    version = "0.5.1";

    dependencies = [
      "gssapi"
      "net-ssh"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "120mns6drrapn8i63cbgxngjql4cyclv6asyrkgc87bv5prlh50c";
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

  optimist = {
    version = "3.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kp3f8g7g7cbw5vfkmpdv71pphhpcxk3lpc892mj9apkd7ys1y4c";
      type = "gem";
    };
  };

  orchestrator_client = {
    version = "0.7.1";

    dependencies = [
      "faraday"
      "faraday-net_http_persistent"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iij18nwivxflzyxfxhx5d0i5085hx1fa87spvi980lq31akhnwy";
      type = "gem";
    };
  };

  prime = {
    version = "0.1.4";

    dependencies = [
      "forwardable"
      "singleton"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pi2g9sd9ssyrpvbybh4skrgzqrv0rrd1q7ylgrsd519gjzmwxad";
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

  puppet = {
    version = "8.10.0";

    dependencies = [
      "concurrent-ruby"
      "deep_merge"
      "facter"
      "fast_gettext"
      "getoptlong"
      "locale"
      "multi_json"
      "puppet-resource_api"
      "scanf"
      "semantic_puppet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fia3ji6isnqz4a31aq8k4nd8p7vkxn80hhgqfdc8kkrba7xxxgj";
      type = "gem";
    };
  };

  puppet-resource_api = {
    version = "1.9.0";
    dependencies = [ "hocon" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rxy5s7hl707x4sc1b4v2yqyii6pkym2gmsam3ri0f0xmmzyg0jb";
      type = "gem";
    };
  };

  puppet-strings = {
    version = "4.1.3";

    dependencies = [
      "rgen"
      "yard"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gna12w39bjnczbqdz4gmlizqxhja8h4wvgn1qlpa3zm4w09xlcw";
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

  puppetfile-resolver = {
    version = "0.6.3";

    dependencies = [
      "molinillo"
      "semantic_puppet"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kil8sbrl9c34ygrgm35893zygr4j6fjvfhbs4rs0b5n3cjrainm";
      type = "gem";
    };
  };

  r10k = {
    version = "4.1.0";

    dependencies = [
      "colored2"
      "cri"
      "gettext-setup"
      "jwt"
      "log4r"
      "minitar"
      "multi_json"
      "puppet_forge"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k3fr2f0pwyrabs12wqig31f37sqrqs8qza7jrn01d6blvhvkrb4";
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

  reline = {
    version = "0.6.2";
    dependencies = [ "io-console" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ii8l0q5zkang3lxqlsamzfz5ja7jc8ln905isfdawl802k2db8x";
      type = "gem";
    };
  };

  rexml = {
    version = "3.4.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jmbf6lf7pcyacpb939xjjpn1f84c3nw83dy3p1lwjx0l2ljfif7";
      type = "gem";
    };
  };

  rgen = {
    version = "0.10.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wgk4brd1v63ivdh5nnlkynfxk8m7bac9q50ydgq3d50hx4ghy6r";
      type = "gem";
    };
  };

  ruby_smb = {
    version = "1.1.0";

    dependencies = [
      "bindata"
      "rubyntlm"
      "windows_error"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "125pimmaskp13nkk5j138nfk1kd8n91sfdlx4dhj2j9zk342wsf4";
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

  scanf = {
    version = "1.0.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "000vxsci3zq8m1wl7mmppj7sarznrqlm6v2x2hdfmbxcwpvvfgak";
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

  singleton = {
    version = "0.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y2pc7lr979pab5n5lvk3jhsi99fhskl5f2s6004v8sabz51psl3";
      type = "gem";
    };
  };

  terminal-table = {
    version = "3.0.2";
    dependencies = [ "unicode-display_width" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14dfmfjppmng5hwj7c5ka6qdapawm3h6k9lhn8zj001ybypvclgr";
      type = "gem";
    };
  };

  text = {
    version = "1.3.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x6kkmsr49y3rnrin91rv8mpc3dhrf3ql08kbccw8yffq61brfrg";
      type = "gem";
    };
  };

  thor = {
    version = "1.2.2";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0k7j2wn14h1pl4smibasw0bp66kg626drxb59z7rzflch99cd4rg";
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

  windows_error = {
    version = "0.1.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1825v7hvcl0xss6scyfv76i0cs0kvj72wy20kn7xqylw9avjga2r";
      type = "gem";
    };
  };

  winrm = {
    version = "2.3.9";

    dependencies = [
      "builder"
      "erubi"
      "gssapi"
      "gyoku"
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
      sha256 = "01jxpshw5kx5ha21ymaaj14vibv5bvm0dd80ccc6xl3jaxy7cszg";
      type = "gem";
    };
  };

  winrm-fs = {
    version = "1.3.5";

    dependencies = [
      "erubi"
      "logging"
      "rubyzip"
      "winrm"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gb91k6s1yjqw387x4w1nkpnxblq3pjdqckayl0qvz5n3ygdsb0d";
      type = "gem";
    };
  };

  yard = {
    version = "0.9.36";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1r0b8w58p7gy06wph1qdjv2p087hfnmhd9jk23vjdj803dn761am";
      type = "gem";
    };
  };
}
