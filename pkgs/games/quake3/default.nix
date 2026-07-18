callPackage: rec {
  # runnable quakes with different configurations / mods
  quake3arena = quake3wrapper {
    pname = "quake3";

    paks = [
      quake3arenadata
      quake3pointrelease
    ];
  };

  quake3arena-hires = quake3wrapper {
    pname = "quake3";

    paks = [
      quake3arenadata
      quake3pointrelease
      quake3hires
    ];
  };

  # data files
  quake3arenadata = callPackage ./content/arena.nix { };

  quake3demo = quake3wrapper {
    pname = "quake3-demo";

    paks = [
      quake3demodata
      quake3pointrelease
    ];
  };

  quake3demo-hires = quake3wrapper {
    pname = "quake3-demo";

    paks = [
      quake3demodata
      quake3pointrelease
      quake3hires
    ];
  };

  quake3demodata = callPackage ./content/demo.nix { };
  quake3hires = callPackage ./content/hires.nix { };
  quake3pointrelease = callPackage ./content/pointrelease.nix { };
  # main entry point to create a runnable quake3
  quake3wrapper = callPackage ./wrapper { };
}
