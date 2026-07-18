args:
import ../temurin-bin/jdk-linux-base.nix (
  {
    brand-name = "IBM Semeru Runtime";
    name-prefix = "semeru";
  }
  // args
)
