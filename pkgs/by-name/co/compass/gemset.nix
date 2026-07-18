{
  chunky_png = {
    version = "1.4.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1znw5x86hmm9vfhidwdsijz8m38pqgmv98l9ryilvky0aldv7mc9";
      type = "gem";
    };
  };

  compass = {
    version = "1.0.3";

    dependencies = [
      "chunky_png"
      "compass-core"
      "compass-import-once"
      "rb-fsevent"
      "rb-inotify"
      "sass"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lfi83w8z75czr0pf0rmj9hda22082h3cmvczl8r1ma9agf88y2c";
      type = "gem";
    };
  };

  compass-core = {
    version = "1.0.3";

    dependencies = [
      "multi_json"
      "sass"
    ];

    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yaspqwdmzwdcqviclbs3blq7an16pysrfzylz8q1gxmmd6bpj3a";
      type = "gem";
    };
  };

  compass-import-once = {
    version = "1.0.5";
    dependencies = [ "sass" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bn7gwbfz7jvvdd0qdfqlx67fcb83gyvxqc7dr9fhcnks3z8z5rq";
      type = "gem";
    };
  };

  ffi = {
    version = "1.15.4";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ssxcywmb3flxsjdg13is6k01807zgzasdhj4j48dm7ac59cmksn";
      type = "gem";
    };
  };

  multi_json = {
    version = "1.15.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      type = "gem";
    };
  };

  rb-fsevent = {
    version = "0.11.0";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qsx9c4jr11vr3a9s5j83avczx9qn9rjaf32gxpc2v451hvbc0is";
      type = "gem";
    };
  };

  rb-inotify = {
    version = "0.10.1";
    dependencies = [ "ffi" ];
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
  };

  sass = {
    version = "3.4.25";
    groups = [ "default" ];
    platforms = [ ];

    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kfpcwh8dgw4lc81qglkvjl73689jy3g7196zkxm4fpskg1p5lkw";
      type = "gem";
    };
  };
}
