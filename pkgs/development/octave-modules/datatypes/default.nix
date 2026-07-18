{
  lib,
  fetchFromGitHub,
  buildOctavePackage,
  nix-update-script,
}:

buildOctavePackage rec {
  pname = "datatypes";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "pr0m1th3as";
    repo = "datatypes";
    tag = "release-${version}";
    sha256 = "sha256-e7xHit/EvsNCzWWA5tuqVMwoUvJo09gNma7RrDd2ib0=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=release-(.*)" ]; };

  meta = {
    description = "Extra data types for GNU Octave";
    homepage = "https://gnu-octave.github.io/packages/datatypes/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
