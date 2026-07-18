{
  lib,
  fetchFromGitHub,
  check-jsonschema,
  mkTmuxPlugin,
  python3,
}:
mkTmuxPlugin {
  version = "0-unstable-2024-06-08";

  src = fetchFromGitHub {
    owner = "alexwforsythe";
    repo = "tmux-which-key";
    rev = "1f419775caf136a60aac8e3a269b51ad10b51eb6";
    hash = "sha256-X7FunHrAexDgAlZfN+JOUJvXFZeyVj9yu6WRnxMEA8E=";
  };

  postPatch = ''
    substituteInPlace plugin.sh.tmux --replace-fail \
      python3 "${lib.getExe (python3.withPackages (ps: with ps; [ pyyaml ]))}"
  '';

  buildInputs = [
    check-jsonschema
    (python3.withPackages (ps: with ps; [ pyyaml ]))
  ];

  preInstall = ''
    rm -rf plugin/pyyaml
    ln -s ${python3.pkgs.pyyaml.src} plugin/pyyaml
  '';

  postInstall = ''
    patchShebangs plugin.sh.tmux plugin/build.py
  '';

  pluginName = "tmux-which-key";
  rtpFilePath = "plugin.sh.tmux";

  meta = {
    description = "Tmux plugin that allows users to select actions from a customizable popup menu";
    homepage = "https://github.com/alexwforsythe/tmux-which-key";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ novaviper ];
    platforms = lib.platforms.unix;
  };
}
