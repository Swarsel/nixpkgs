import ./generic.nix {
  version = "0.5.21.1";
  hash = "sha256-andOWZmgWYIPATEk0V+mHmReL+quG81azwPkBMoo9OE=";

  url =
    {
      dovecotMajorMinor,
      version,
    }:
    "https://pigeonhole.dovecot.org/releases/${dovecotMajorMinor}/dovecot-${dovecotMajorMinor}-pigeonhole-${version}.tar.gz";
}
