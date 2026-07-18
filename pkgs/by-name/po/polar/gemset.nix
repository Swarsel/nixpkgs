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

  ffi = {
    version = "1.17.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fgwn1grxf4zxmyqmb9i4z2hr111585n9jnk17y6y7hhs7dv1xi6";
      type = "gem";
    };
  };

  google-protobuf = {
    version = "4.30.0";

    dependencies = [
      "bigdecimal"
      "rake"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1sa2v1fffc0yc3alpqz4a35gjc0n3mavskdwci6yrc6crad289s4";
      type = "gem";
    };
  };

  libusb = {
    version = "0.7.2";

    dependencies = [
      "ffi"
      "mini_portile2"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zxgbwqsipkia02lmxyq7a6c3hplw1ih0dsrlgqf15ff0z6qpj2r";
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

  nokogiri = {
    version = "1.18.3";

    dependencies = [
      "mini_portile2"
      "racc"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0npx535cs8qc33n0lpbbwl0p9fi3a5bczn6ayqhxvknh9yqw77vb";
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

  rake = {
    version = "13.2.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17850wcwkgi30p7yqh60960ypn7yibacjjha0av78zaxwvd3ijs6";
      type = "gem";
    };
  };

  rubyserial = {
    version = "0.6.0";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vj5yan6srbvkf5vfp9d9b9z8wyygd0zxcy54c35yhkjl6kwd22q";
      type = "gem";
    };
  };
}
