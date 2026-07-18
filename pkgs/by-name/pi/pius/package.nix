{
  lib,
  fetchFromGitHub,
  gnupg,
  perl,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pius";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "jaymzh";
    repo = "pius";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fsBG5F2GFRMXjRqmooxqhM4AEVV7Q9upQp5HY09vB1E=";
  };

  buildInputs = [ perl ];
  build-system = with python3Packages; [ setuptools ];
  namePrefix = "";

  patchPhase = ''
    for file in libpius/constants.py pius-keyring-mgr; do
      sed -i "$file" -E -e's|/usr/bin/gpg2?|${gnupg}/bin/gpg|g'
    done
  '';

  pyproject = true;

  meta = {
    description = "PGP Individual UID Signer (PIUS), quickly and easily sign UIDs on a set of PGP keys";

    longDescription = ''
      This software will allow you to quickly and easily sign each UID on
      a set of PGP keys.  It is designed to take the pain out of the
      sign-all-the-keys part of PGP Keysigning Party while adding security
      to the process.
    '';

    homepage = "https://www.phildev.net/pius/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.gnu ++ lib.platforms.linux;
  };
})
