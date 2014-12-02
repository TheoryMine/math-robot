(* basic values *)
val rootDir = OS.FileSys.getDir();
(OS.FileSys.chDir ("../../IsaP-trunk/isaplib"); 
use "ROOT.ML"; 
OS.FileSys.chDir rootDir);

PolyML.Project.make "ROOT2.ML";
