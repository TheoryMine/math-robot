structure File_Util =
struct

  fun dirExists s = (OS.FileSys.isDir s) handle OS.SysErr _ => false;

  (* Given directories to create as a list, and root path to create them from *)
  val mkPathFromDirList = fold
    (fn nextDir => fn pathsSoFar =>
     let val nextPath = pathsSoFar ^ "/" ^ nextDir
     in
       if not (dirExists nextPath) then
         (writeln ("mkdir: " ^ nextPath);
          OS.FileSys.mkDir nextPath;
          nextPath)
       else nextPath
     end);

  val pathAsList = Library.space_explode "/";

  fun absolutePath p =
    if hd (pathAsList p) = "" then p else (OS.FileSys.getDir ()) ^ "/" ^ p;

  (* Creates the given path, which if it does not start with "/" is assumed to
     be relative, and otherwise is absolute. Returns final created path as a
     string *)
  fun mkPath pathString =
    let val dirs = pathAsList (absolutePath pathString)
    in mkPathFromDirList (tl dirs) (hd dirs) end;

  (* Write string to file *)
  fun writeStringToFilepath {path, str} =
    let
      val {dir, ...} = OS.Path.splitDirFile path
      val _ = mkPath dir;
      val outstream = TextIO.openOut path
    in
      TextIO.output (outstream, str);
      TextIO.closeOut outstream
    end;

end;
