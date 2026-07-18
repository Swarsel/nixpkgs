{ buildOpenRAEngine, dotnetCorePackages }:

buildOpenRAEngine {
  version = "20250531";
  build = "bleed";
  deps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_8_0-bin;
  hash = "sha256-LQSHMmjwNAdnoq16MNjjXyvuFy9o87eXrsdRFqmoV24=";
  rev = "9c8470d18e3d850583e64a5defc5d3492ba5055b";
}
