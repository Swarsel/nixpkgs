{ lib }:
{
  meta = {
    description = "A tool to control the generation of non-source files from sources";
    homepage = "https://www.gnu.org/software/make";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "make";
    teams = [ lib.teams.minimal-bootstrap ];
  };
}
