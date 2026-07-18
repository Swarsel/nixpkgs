{ replaceVarsWith, runtimeShell }:

replaceVarsWith {
  src = ./xargs-j.sh;
  dir = "bin";
  isExecutable = true;
  name = "xargs-j";

  replacements = {
    inherit runtimeShell;
  };
}
