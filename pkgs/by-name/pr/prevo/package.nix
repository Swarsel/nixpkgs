{
  lib,
  makeWrapper,
  man,
  prevo-data,
  prevo-tools,
  symlinkJoin,
}:

symlinkJoin {
  inherit (prevo-tools) version;
  pname = "prevo";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/prevo \
      --prefix PATH ":" "${lib.makeBinPath [ man ]}" \
      --suffix XDG_DATA_DIRS : "${prevo-data}/share" \

  '';

  paths = [ prevo-tools ];

  meta = {
    description = "Offline version of the Esperanto dictionary Reta Vortaro";

    longDescription = ''
      PReVo is the "portable" ReVo, i.e., the offline version
      of the Esperanto dictionary Reta Vortaro.
    '';

    homepage = "https://github.com/bpeel/prevodb";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      das-g
    ];

    mainProgram = "prevo";
  };
}
