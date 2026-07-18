{ buildOpenRAEngine, dotnetCorePackages }:

buildOpenRAEngine {
  version = "20250330";
  build = "release";
  deps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  hash = "sha256-chWkzn/NLZh2gOua9kE0ubRGjGCC0LvtZSWHBgXKqHw=";
}
