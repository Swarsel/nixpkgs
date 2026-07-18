{
  lib,
  fetchFromGitLab,
  libfprint,
}:

# for the curious, "tod" means "Touch OEM Drivers" meaning it can load
# external .so's.
libfprint.overrideAttrs (
  {
    mesonFlags ? [ ],
    postPatch ? "",
    ...
  }:
  let
    version = "1.94.9+tod1";
  in
  {
    inherit version;
    pname = "libfprint-tod";

    src = fetchFromGitLab {
      owner = "3v1n0";
      repo = "libfprint";
      rev = "v${version}";
      hash = "sha256-xkywuFbt8EFJOlIsSN2hhZfMUhywdgJ/uT17uiO3YV4=";
      domain = "gitlab.freedesktop.org";
    };

    # Different source than libfprint, so override any patches, because they
    # would only apply to the original source tree
    patches = [ ];

    postPatch = ''
      ${postPatch}
      patchShebangs \
        ./libfprint/tod/tests/*.sh \
        ./tests/*.py \
        ./tests/*.sh
    '';

    mesonFlags = [
      # Include virtual drivers for fprintd tests
      "-Ddrivers=all"
      "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
      "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    ];

    meta = {
      description = "Library designed to make it easy to add support for consumer fingerprint readers, with support for loaded drivers";
      homepage = "https://gitlab.freedesktop.org/3v1n0/libfprint";
      license = lib.licenses.lgpl21;
      platforms = lib.platforms.linux;
    };
  }
)
