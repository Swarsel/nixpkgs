args:
import ../temurin-bin/jdk-darwin-base.nix (
  {
    brand-name = "IBM Semeru Runtime";
    name-prefix = "semeru";
  }
  // args
)
