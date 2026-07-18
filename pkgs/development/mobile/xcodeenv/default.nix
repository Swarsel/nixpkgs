{ callPackage }:

rec {
  buildApp = callPackage ./build-app.nix { inherit composeXcodeWrapper; };
  composeXcodeWrapper = callPackage ./compose-xcodewrapper.nix { };
  simulateApp = callPackage ./simulate-app.nix { inherit composeXcodeWrapper; };
}
