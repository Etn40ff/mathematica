BeginPackage["Attach`"]

AttachFile::usage = "AttachFile[fileName] Attach the file fileName to the current session."
DetachFile::usage = "DetachFile[fileName] Detach the file fileName from the current session."
ListAttachedFiles::usage = "ListAttachedFiles[] List all attached files"

Begin["`Private`"]

attachedFiles = Association[];

updatedQ[fileName_] := With[
    {modificationDate = FileDate[fileName, "Modification"]}, 
    If[TrueQ[attachedFiles[[fileName,2]] == modificationDate], False, attachedFiles[[fileName,2]] = modificationDate; True ]
];

AttachTask[fileName_] := CreateScheduledTask[If[updatedQ[fileName], Get[fileName], ## &[]]]

AttachFile[fileName_] := If[!MemberQ[Keys[attachedFiles],fileName], With[{task=AttachTask[fileName]}, attachedFiles[fileName] = {task, {}}; StartScheduledTask[task]; ]]

ListAttachedFiles[] := Keys[attachedFiles]

DetachFile[fileName_] := If[MemberQ[Keys[attachedFiles],fileName], StopScheduledTask[attachedFiles[[fileName,1]]]; attachedFiles=Delete[attachedFiles,fileName];]

End[ ]

EndPackage[ ]
