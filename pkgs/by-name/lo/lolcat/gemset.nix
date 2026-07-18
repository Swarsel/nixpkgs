{
  lolcat = {
    version = "100.0.1";

    dependencies = [
      "manpages"
      "optimist"
      "paint"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13p8i08vdqfg2bqyjkl8jsp7gw8cf6r68i8plp9zqavlqadqlg4q";
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

  optimist = {
    version = "3.0.1";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vg2chy1cfmdj6c1gryl8zvjhhmb3plwgyh1jfnpq4fnfqv7asrk";
      type = "gem";
    };
  };

  paint = {
    version = "2.3.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1r9vx3wcx0x2xqlh6zqc81wcsn9qjw3xprcsv5drsq9q80z64z9j";
      type = "gem";
    };
  };
}
