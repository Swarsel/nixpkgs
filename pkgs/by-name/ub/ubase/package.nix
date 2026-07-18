{
  lib,
  stdenv,
  fetchgit,
  libxcrypt,
  testers,
  unstableGitUpdater,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ubase";
  version = "0-unstable-2025-12-30";

  src = fetchgit {
    url = "https://git.suckless.org/ubase";
    rev = "e8249b49ca3e02032dece5e0cdac3d236667a6d9";
    hash = "sha256-/XwDmhIBjISUyS1hBMcfBe5i4ISKj6sJTGb4lYfJqO0=";
  };

  strictDeps = true;
  buildInputs = [ libxcrypt ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  buildFlags = [ "ubase-box" ];
  enableParallelBuilding = true;
  installTargets = [ "ubase-box-install" ];

  passthru = {
    tests = {
      ddCopiesBytes = testers.runCommand {
        buildInputs = [ finalAttrs.finalPackage ];
        name = "ubase-dd-copies-bytes";

        script = ''
          dd if=/dev/zero of=test.bin bs=1 count=4
          set -- $(stat -t test.bin)
          [ "$1" = "test.bin" ] && [ "$2" = "4" ]
          touch $out
        '';
      };

      idMatchesUid = testers.runCommand {
        buildInputs = [ finalAttrs.finalPackage ];
        name = "ubase-id-matches-uid";

        script = ''
          [ "$(id -u)" = "$UID" ]
          touch $out
        '';
      };

      pagesizePositive = testers.runCommand {
        buildInputs = [ finalAttrs.finalPackage ];
        name = "ubase-pagesize-positive";

        script = ''
          [ "$(pagesize)" -gt 0 ]
          touch $out
        '';
      };

      whichIdIsBox = testers.runCommand {
        buildInputs = [
          which
          finalAttrs.finalPackage
        ];

        name = "ubase-which-id-is-box";

        script = ''
          [ $(which id) -ef $(which ubase-box) ]
          touch $out
        '';
      };
    };

    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Linux base utilities from suckless.org";
    homepage = "https://core.suckless.org/ubase/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.linux;
    mainProgram = "ubase-box";
  };
})
