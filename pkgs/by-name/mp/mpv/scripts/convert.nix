{
  lib,
  buildLua,
  fetchgit,
  libnotify,
  mkvtoolnix-cli,
  unstableGitUpdater,
  yad,
}:

buildLua {
  pname = "mpv-convert-script";
  version = "0-unstable-2015-07-02";

  src = fetchgit {
    url = "https://gist.github.com/Zehkul/25ea7ae77b30af959be0";
    rev = "f95cee43e390e843a47e8ec9d1711a12a8cd343d";
    sha256 = "13m7l4sy2r8jv2sfrb3vvqvnim4a9ilnv28q5drlg09v298z3mck";
  };

  patches = [ ./convert.patch ];

  postPatch = ''
    substituteInPlace convert_script.lua \
      --replace-fail 'mkvpropedit_exe = "mkvpropedit"' \
                'mkvpropedit_exe = "${lib.getExe' mkvtoolnix-cli "mkvpropedit"}"' \
      --replace-fail 'mkvmerge_exe = "mkvmerge"' \
                'mkvmerge_exe = "${lib.getExe' mkvtoolnix-cli "mkvmerge"}"' \
      --replace-fail 'yad_exe = "yad"' \
                'yad_exe = "${lib.getExe yad}"' \
      --replace-fail 'notify_send_exe = "notify-send"' \
                'notify_send_exe = "${lib.getExe libnotify}"'
  '';

  scriptPath = "convert_script.lua";
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Convert parts of a video while you are watching it in mpv";

    longDescription = ''
      When this script is loaded into mpv, you can hit Alt+W to mark the beginning
      and Alt+W again to mark the end of the clip. Then a settings window opens.
    '';

    homepage = "https://gist.github.com/Zehkul/25ea7ae77b30af959be0";
    # author was asked to add a license https://gist.github.com/Zehkul/25ea7ae77b30af959be0#gistcomment-3715700
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
