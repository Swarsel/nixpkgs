{
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  srcOnly,
}:
rec {
  version = "2.2.5";

  src = srcOnly {
    inherit version stdenv;

    patches = [
      # fix installing translations
      # remove on next release
      (
        assert version == "2.2.5";
        fetchpatch {
          hash = "sha256-VUT86kF0ZHLGK457ZrrIBMeiZqg/rPRpbkBA/ua9rU8=";
          url = "https://gitlab.gnome.org/World/OpenPaperwork/paperwork/-/commit/b8e2633ace0f3d9d57e68c27db8f594b8a5ddd7e.patch";
        }
      )
    ];

    pname = "paperwork-patched-src";

    src = fetchFromGitLab {
      owner = "OpenPaperwork";
      repo = "paperwork";
      rev = version;
      sha256 = "sha256-PRh0ohmPLwpM76qYfbExFqq4OK6Hm0fbdzrjXungSoY=";
      domain = "gitlab.gnome.org";
      group = "World";
    };
  };

  sample_documents = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    group = "World";
    owner = "OpenPaperwork";
    repo = "paperwork-test-documents";
    # https://gitlab.gnome.org/World/OpenPaperwork/paperwork/-/blob/master/paperwork-gtk/src/paperwork_gtk/model/help/screenshot.sh see TEST_DOCS_TAG
    rev = "2.1";
    sha256 = "0m79fgc1ycsj0q0alqgr0axn16klz1sfs2km1h83zn3kysqcs6xr";
  };

}
