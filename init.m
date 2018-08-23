(** User Mathematica initialization file **)

(** Emulate SageMath's %attach magic **)
Needs["Attach`"]

(** If we are running in a terminal enable JavaGraphics **)
If[ $FrontEnd == Null, Get["JavaGraphics`"]]

(** Enable easy latex output **)
Needs["MaTeX`"]
