{ stdenv, pkgs }:
rec {
  inherit (pkgs) eggDerivation fetchegg;

  base64 = eggDerivation {
    pname = "base64";
    version = "3.3.1";

    src = fetchegg {
      sha256 = "0wmldiwwg1jpcn07wb906nc53si5j7sa83wgyq643xzqcx4v4x1d";
      name = "base64";
      version = "3.3.1";
    };

    buildInputs = [

    ];
  };

  defstruct = eggDerivation {
    pname = "defstruct";
    version = "1.7";

    src = fetchegg {
      sha256 = "1rkqk9jxd6vnlvkwzqg8mc7bsw050fgmxfj84y66lf0a14n5r5dg";
      name = "defstruct";
      version = "1.7";
    };

    buildInputs = [

    ];
  };

  http-client = eggDerivation {
    pname = "http-client";
    version = "0.18";

    src = fetchegg {
      sha256 = "1b9x66kfcglld4xhm06vba00gw37vr07c859kj7lmwnk9nwhcplg";
      name = "http-client";
      version = "0.18";
    };

    buildInputs = [
      intarweb
      uri-common
      simple-md5
      sendfile
    ];
  };

  intarweb = eggDerivation {
    pname = "intarweb";
    version = "1.7.1";

    src = fetchegg {
      sha256 = "0pqgwgy4jynlsr3l52qsiwm75qgs7n86kwssaawzp9y34y80awpg";
      name = "intarweb";
      version = "1.7.1";
    };

    buildInputs = [
      defstruct
      uri-common
      base64
    ];
  };

  matchable = eggDerivation {
    pname = "matchable";
    version = "3.7";

    src = fetchegg {
      sha256 = "1vc9rpb44fhn0n91hzglin986dw9zj87fikvfrd7j308z22a41yh";
      name = "matchable";
      version = "3.7";
    };

    buildInputs = [

    ];
  };

  sendfile = eggDerivation {
    pname = "sendfile";
    version = "1.11";

    src = fetchegg {
      sha256 = "15gm380asvj87f3bqb7rz4mz6znnk6r00rdy3njx9ay0qkxi3q9y";
      name = "sendfile";
      version = "1.11";
    };

    buildInputs = [

    ];
  };

  simple-md5 = eggDerivation {
    pname = "simple-md5";
    version = "0.0.1";

    src = fetchegg {
      sha256 = "1h0b51p9wl1dl3pzs39hdq3hk2qnjgn8n750bgmh0651g4lzmq3i";
      name = "simple-md5";
      version = "0.0.1";
    };

    buildInputs = [

    ];
  };

  uri-common = eggDerivation {
    pname = "uri-common";
    version = "1.4";

    src = fetchegg {
      sha256 = "01ds1gixcn4rz657x3hr4rhw2496hsjff42ninw0k39l8i1cbh7c";
      name = "uri-common";
      version = "1.4";
    };

    buildInputs = [
      uri-generic
      defstruct
      matchable
    ];
  };

  uri-generic = eggDerivation {
    pname = "uri-generic";
    version = "2.46";

    src = fetchegg {
      sha256 = "10ivf4xlmr6jcm00l2phq1y73hjv6g3qgr38ycc8rw56wv6sbm4g";
      name = "uri-generic";
      version = "2.46";
    };

    buildInputs = [
      matchable
    ];
  };
}
