{
  fetchFromGitLab,
  callPackage,
  fetchpatch,
}:
let
  mkVariant =
    {
      hash,
      version,
      patches ? [ ],
    }:
    callPackage ./generic.nix {
      inherit version patches;

      src = fetchFromGitLab {
        inherit hash;
        owner = "emersion";
        repo = "libliftoff";
        rev = "v${version}";
        domain = "gitlab.freedesktop.org";
      };
    };
in
{
  libliftoff_0_4 = mkVariant {
    version = "0.4.1";

    patches = [
      # Pull gcc-14 fix:
      #   https://gitlab.freedesktop.org/emersion/libliftoff/-/merge_requests/78
      (fetchpatch {
        hash = "sha256-Y8x1RK3o/I9bs/ZOLeC4t9AIK78l0QnlBWHhiVC+sz8=";
        name = "libliftoff-gcc-14-calloc.patch";
        url = "https://gitlab.freedesktop.org/emersion/libliftoff/-/commit/29a06add8ef184f85e37ff8abdc34fbaa2f4ee1e.patch";
      })
    ];

    hash = "sha256-NPwhsd6IOQ0XxNQQNdaaM4kmwoLftokV86WYhoa5csY=";
  };

  libliftoff_0_5 = mkVariant {
    version = "0.5.0";
    hash = "sha256-PcQY8OXPqfn8C30+GAYh0Z916ba5pik8U0fVpZtFb5g=";
  };
}
