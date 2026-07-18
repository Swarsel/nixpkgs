{
  icalendar = {
    version = "2.8.0";
    dependencies = [ "ice_cube" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11zfs0l8y2a6gpf0krm91d0ap2mnf04qky89dyzxwaspqxqgj174";
      type = "gem";
    };
  };

  icalendar-recurrence = {
    version = "1.1.3";

    dependencies = [
      "icalendar"
      "ice_cube"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06li3cdbwkd9y2sadjlbwj54blqdaa056yx338s4ddfxywrngigh";
      type = "gem";
    };
  };

  ice_cube = {
    version = "0.16.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dri4mcya1fwzrr9nzic8hj1jr28a2szjag63f9k7p2bw9fpw4fs";
      type = "gem";
    };
  };

  iso-639 = {
    version = "0.3.5";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k1r8wgk6syvpsl3j5qfh5az5w4zdvk0pvpjl7qspznfdbp2mn71";
      type = "gem";
    };
  };

  omnievent = {
    version = "0.1.0.pre11";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xiz1jag2z8agjk1mycw44lkgrq7nfj2m6gx2v1zr8c6p2wvk4lj";
      type = "gem";
    };
  };

  omnievent-api = {
    version = "0.1.0.pre5";
    dependencies = [ "omnievent" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nlp8vmsachbc8s8h6h34h9gw5i3yd6zbcs7sdkbhdwsqaf61ypp";
      type = "gem";
    };
  };

  omnievent-google = {
    version = "0.1.0.pre8";

    dependencies = [
      "omnievent"
      "omnievent-api"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ma15ijrf0dq4mlghg3vrhz62llhfp7k6cq7nfwy12h229gnzdrx";
      type = "gem";
    };
  };

  omnievent-icalendar = {
    version = "0.1.0.pre9";
    dependencies = [ "omnievent" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl634wgah2dv851dhv18hkmg1p6a1laa2f9blizlizvnvi5g1g5";
      type = "gem";
    };
  };

  omnievent-outlook = {
    version = "0.1.0.pre11";

    dependencies = [
      "omnievent"
      "omnievent-api"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "072aycqq94w5bfj9nda8inxpc88a4bqn1l1jar0c4dcpyadqnd5r";
      type = "gem";
    };
  };
}
