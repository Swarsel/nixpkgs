{
  callPackage,
  flex,
  sratom,
  ...
}@args:

callPackage ./generic.nix (
  args
  // {
    pname = "sherlock";
    version = "0.28.0";

    additionalBuildInputs = [
      sratom
      flex
    ];

    description = "Plugins for visualizing LV2 atom, MIDI and OSC events";
    sha256 = "07zj88s1593fpw2s0r3ix7cj2icfd9zyirsyhr2i8l6d30b6n6fb";
  }
)
