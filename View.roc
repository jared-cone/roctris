interface View
    exposes [
        Cell,
        View,
        init,
        string,
        rect,
        points,
    ]
    imports [
        Color.{Color, Rgb8},
        Util,
    ]
    
Cell : {
    grapheme : Str,   # TODO investigate if perf improves by using an index into a grapheme list instead
    foreColor : Rgb8, # TODO investigate if color needs padding
    backColor : Rgb8,
}

View : {
    width : Nat,
    height : Nat,
    cells : List Cell,
}

toRgb8 = \c -> Color.toRgb8 c

init : Nat, Nat, Str, Color, Color -> View
init = \width, height, grapheme, foreColor, backColor ->
    
    cell = {grapheme, foreColor : toRgb8 foreColor, backColor : toRgb8 backColor}
    cells = List.repeat cell (width * height)
    { width, height, cells }

positionToIndex : View, Nat, Nat -> Nat
positionToIndex = \view, x, y ->
    idx = y * view.width + x
    if idx >= 0 && idx < (view.width * view.height) then idx else 0
    
toNat : Int a -> Nat
toNat = \i ->
    if i < 0 then 0 else Num.toNat i
    
# TODO compiler crashes when this was closure
stringSet = \view, cellTemplate, cellIdx, graphemes, graphemeIdx ->
    if graphemeIdx < (List.len graphemes) then
        grapheme = List.get graphemes graphemeIdx |> Result.withDefault ""
        cell = {cellTemplate & grapheme}
        cells = List.set view.cells (cellIdx + graphemeIdx) cell
        stringSet {view & cells} cellTemplate cellIdx graphemes (graphemeIdx + 1)
    else
        view

string : View, Int ix, Int iy, Str, Color, Color -> View
string = \view, x, y, str, foreColor, backColor ->
    graphemes = strGraphemes str
    stringGraphemes view (toNat x) (toNat y) graphemes (toRgb8 foreColor) (toRgb8 backColor)
    
stringGraphemes : View, Nat, Nat, List Str, Rgb8, Rgb8 -> View
stringGraphemes = \view, x, y, graphemes, foreColor, backColor ->
    cellTemplate = {grapheme : "", foreColor, backColor}
    cellIdx = positionToIndex view x y
    stringSet view cellTemplate cellIdx graphemes 0
    
# TODO compiler crashes when this was a closure
rectColumns = \view, x, y, w, graphemes, foreColor, backColor, count ->
    if count < w then
        graphemeCount = Util.min (List.len graphemes) (w - count)
        graphemeSublist = List.takeFirst graphemes graphemeCount
        stringGraphemes view x y graphemeSublist foreColor backColor
        |> rectColumns (x + graphemeCount) y w graphemes foreColor backColor (count + graphemeCount)
    else
        view
    
# TODO compiler crashes when this was a closure
rectRows = \view, x, y, w, h, graphemes, foreColor, backColor, count ->
    if count < h then
        rectColumns view x y w graphemes foreColor backColor 0
        |> rectRows x (y + 1) w h graphemes foreColor backColor (count + 1)
    else
        view
        
rect : View, {x : Int ix, y : Int iy, w : Int iw, h : Int ih}, Str, Color, Color -> View
rect = \view, {x, y, w, h}, str, foreColor, backColor ->
    graphemes = strGraphemes str
    rectRows view (toNat x) (toNat y) (toNat w) (toNat h) graphemes (toRgb8 foreColor) (toRgb8 backColor) 0
    
points : View, Str, Color, Color, List {x : Int ix, y : Int iy} -> View
points = \view, str, foreColor, backColor, vectors ->
    List.walk vectors view (\v, p -> 
        string v (toNat p.x) (toNat p.y) str (toRgb8 foreColor) (toRgb8 backColor))
        
# TODO Str.graphemes is not exposed
strGraphemes : Str -> List Str
strGraphemes = \str ->
    utf8 = Str.toUtf8 str
    List.walk utf8 [] (\list, item ->
        grapheme = item |> List.single |> Str.fromUtf8 |> Result.withDefault ""
        List.append list grapheme)