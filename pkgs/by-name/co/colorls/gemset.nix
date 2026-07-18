{
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

  clocale = {
    version = "0.0.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "065pb7hzmd6zndbln4ag94bjpw3hsm71jagsgiqskpxhgrbq03jz";
      type = "gem";
    };
  };

  colorls = {
    version = "1.5.0";

    dependencies = [
      "addressable"
      "clocale"
      "filesize"
      "manpages"
      "rainbow"
      "unicode-display_width"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w7zxzvcbr0nmg1fxqiadfh44a7y687bb6jrq82ql21gr2l3z4xh";
      type = "gem";
    };
  };

  filesize = {
    version = "0.2.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17p7rf1x7h3ivaznb4n4kmxnnzj25zaviryqgn2n12v2kmibhp8g";
      type = "gem";
    };
  };

  manpages = {
    version = "0.6.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11p6ilnfda6af15ks3xiz2pr0hkvdvadnk1xm4ahqlf84dld3fnd";
      type = "gem";
    };
  };

  public_suffix = {
    version = "6.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vqcw3iwby3yc6avs1vb3gfd0vcp2v7q310665dvxfswmcf4xm31";
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
}
