#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off

ListLines false
SetWinDelay 0
SetControlDelay 0
SetKeyDelay -1, -1
try ProcessSetPriority "High"
try DllCall("winmm\\timeBeginPeriod", "uint", 1)   ; таймеры 1 мс вместо ~15.6 мс

CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"

NL := Chr(10)

; ==================== НАСТРОЙКИ ====================
Cfg := {
    ; Окно игры. "" = работать всегда. Пример: "ahk_exe RobloxPlayerBeta.exe"
    win: "",

    ; Зона сканирования (F6 — задать мышью)
    zone: { x1: 866, y1: 501, x2: 1042, y2: 658 },

    ; Запретная зона внутри круга
    hole: { on: true, x1: 913, y1: 541, x2: 1001, y2: 590 },

    ; Ось вращения стрелки. auto = центр hole (или зоны). F7 — задать под курсором.
    center: { auto: true, x: 0, y: 0 },

    ; Что считается белым: яркое и несатурированное
    white: { minBright: 200, maxSat: 30 },

    ; Стрелка: красный доминирует над G и B
    arrow: { minR: 110, domR: 45, maxGB: 150, minCells: 3, hitPadDeg: 1.5 },

    ; Геометрия белого квадрата
    blob: {
        step:      3,      ; шаг сетки, px (2 = точнее, 4 = быстрее)
        minAreaPx: 60,     ; минимальная площадь кластера, px^2
        minSide:   6,
        maxSide:   60,
        maxAspect: 3.0,
        minFill:   0.40,
        mergeGap:  6,      ; склейка кластеров, разрезанных стрелкой, px
        trackDist: 20      ; бонус кандидату рядом с текущей целью, px
    },

    ; ПРЕДСКАЗАНИЕ — сердце скрипта
    predict: {
        on:        true,
        latency:   30,     ; ГЛАВНЫЙ ПАРАМЕТР: SendInput + реакция игры, мс
        lead:      0,      ; доп. смещение: + жать раньше, - позже, мс
        lookahead: 160,    ; дальше в будущее не заглядываем, мс
        lateGrace: 45,     ; проскочили не больше этого — всё равно жмём, мс
        minOmega:  0.03    ; град/мс: медленнее считаем, что стрелка стоит
    },

    tickRate:   6,     ; период проверки, мс
    cooldown:   150,   ; мин. пауза между нажатиями, мс
    moveDist:   25,    ; сдвиг цели = новый скилл-чек, px
    maxHits:    20,    ; предохранитель от бесконечного спама
    resetAfter: 260,   ; мс без цели до сброса счётчика цепочки
    rearmAfter: 200,   ; мс без стрелки до повторного взвода
    targetHold: 220,   ; мс помнить цель, если детект мигнул
    hold:       40,    ; удержание клавиши, мс
    key:        "Space",
    keyMode:    "input",  ; "input" | "event" (если игра игнорит SendInput)
    dpiAware:   false,    ; true только если масштаб экрана 100% и координаты сбиты

    frames:  true,
    markers: true,
    debug:   false
}
; ===================================================

if (Cfg.dpiAware)
    try DllCall("SetThreadDpiAwarenessContext", "ptr", -3)

S := { on: false, armed: true, busy: false, keyDown: false, pressPending: false,
       hits: 0, lastPress: 0, why: "", dbg: "", scanMs: 0,
       tgt: { ok: false, cx: 0, cy: 0, x1: 0, y1: 0, x2: 0, y2: 0, t: 0 },
       hist: [], aPrev: 0, aTot: 0, t0: 0, lastArrow: 0,
       zoneStep: 0, tmpX: 0, tmpY: 0 }

Ov  := { frame: [], hole: [], box: [], tickX: 0, tickY: 0 }
Cap := { g: 0 }

NormRect(r) {
    if (r.x1 > r.x2) {
        t := r.x1
        r.x1 := r.x2
        r.x2 := t
    }
    if (r.y1 > r.y2) {
        t := r.y1
        r.y1 := r.y2
        r.y2 := t
    }
}
NormRect(Cfg.zone)
NormRect(Cfg.hole)
if (Cfg.blob.step < 1)
    Cfg.blob.step := 1

OnExit(OnExitHandler)
OnExitHandler(*) {
    SetTimer CheckSkill, 0
    try SendInput("{" Cfg.key " up}")
    DestroyOverlays()
    Cap.g := 0
    ToolTip(, , , 2)
    try DllCall("winmm\\timeEndPeriod", "uint", 1)
}

; ---------------------- Время и углы ----------------------
QPC() {
    static freq := 0
    if (!freq) {
        f := 0
        DllCall("QueryPerformanceFrequency", "int64*", &f)
        freq := f
    }
    c := 0
    DllCall("QueryPerformanceCounter", "int64*", &c)
    return c * 1000.0 / freq
}

; Угол 0..360 (ось Y вниз)
Ang(dx, dy) {
    if (dx = 0 && dy = 0)
        return 0
    if (dx = 0)
        return (dy > 0) ? 90 : 270
    a := ATan(dy / dx) * 57.29577951308232
    if (dx < 0)
        a += 180
    else if (dy < 0)
        a += 360
    return a
}

; Приведение разницы углов к (-180..180]
AngWrap(d) {
    while (d > 180)
        d -= 360
    while (d <= -180)
        d += 360
    return d
}

; Путь от from до to в направлении движения dir (+1/-1), 0..360
AngFwd(from, to, dir) {
    d := (to - from) * dir
    while (d < 0)
        d += 360
    while (d >= 360)
        d -= 360
    return d
}

; ---------------------- Захват экрана (GDI) ----------------------
class ScreenGrab {
    __New(w, h) {
        this.w := w
        this.h := h
        this.hdcScreen := DllCall("GetDC", "ptr", 0, "ptr")
        this.hdcMem := DllCall("CreateCompatibleDC", "ptr", this.hdcScreen, "ptr")
        bi := Buffer(40, 0)
        NumPut("uint", 40, bi, 0)
        NumPut("int", w, bi, 4)
        NumPut("int", -h, bi, 8)
        NumPut("ushort", 1, bi, 12)
        NumPut("ushort", 32, bi, 14)
        NumPut("uint", 0, bi, 16)
        pBits := 0
        this.hBmp := DllCall("CreateDIBSection", "ptr", this.hdcMem, "ptr", bi, "uint", 0,
            "ptr*", &pBits, "ptr", 0, "uint", 0, "ptr")
        this.pBits := pBits
        this.hOld := DllCall("SelectObject", "ptr", this.hdcMem, "ptr", this.hBmp, "ptr")
    }

    Grab(sx, sy) {
        return DllCall("BitBlt", "ptr", this.hdcMem, "int", 0, "int", 0,
            "int", this.w, "int", this.h,
            "ptr", this.hdcScreen, "int", sx, "int", sy, "uint", 0x00CC0020)
    }

    __Delete() {
        try DllCall("SelectObject", "ptr", this.hdcMem, "ptr", this.hOld)
        try DllCall("DeleteObject", "ptr", this.hBmp)
        try DllCall("DeleteDC", "ptr", this.hdcMem)
        try DllCall("ReleaseDC", "ptr", 0, "ptr", this.hdcScreen)
    }
}

EnsureGrab() {
    z := Cfg.zone
    w := z.x2 - z.x1 + 1
    h := z.y2 - z.y1 + 1
    g := Cap.g
    if (!IsObject(g) || g.w != w || g.h != h)
        Cap.g := ScreenGrab(w, h)
}

GrabZone() {
    EnsureGrab()
    g := Cap.g
    if (!IsObject(g))
        return false
    z := Cfg.zone
    return g.Grab(z.x1, z.y1) ? true : false
}

CenterPt() {
    c := Cfg.center
    if (!c.auto)
        return { x: c.x, y: c.y }
    if (Cfg.hole.on)
        return { x: (Cfg.hole.x1 + Cfg.hole.x2) / 2, y: (Cfg.hole.y1 + Cfg.hole.y2) / 2 }
    return { x: (Cfg.zone.x1 + Cfg.zone.x2) / 2, y: (Cfg.zone.y1 + Cfg.zone.y2) / 2 }
}

; ---------------------- Оверлеи ----------------------
MakeOverlay(x, y, w, h, color, alpha) {
    g := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x8000020")
    g.BackColor := color
    g.Show(Format("x{} y{} w{} h{} NA", x, y, Max(w, 1), Max(h, 1)))
    WinSetTransparent(alpha, g.Hwnd)
    g.ox := x
    g.oy := y
    g.ow := Max(w, 1)
    g.oh := Max(h, 1)
    g.vis := true
    return g
}

PlaceOvRect(g, x, y, w, h) {
    if (!IsObject(g))
        return
    w := Max(w, 1)
    h := Max(h, 1)
    try {
        if (g.vis) {
            if (g.ox != x || g.oy != y || g.ow != w || g.oh != h) {
                WinMove(x, y, w, h, g.Hwnd)
                g.ox := x
                g.oy := y
                g.ow := w
                g.oh := h
            }
        } else {
            g.Show(Format("x{} y{} w{} h{} NA", x, y, w, h))
            g.ox := x
            g.oy := y
            g.ow := w
            g.oh := h
            g.vis := true
        }
    }
}

HideOv(g) {
    if (!IsObject(g))
        return
    try {
        if (g.vis) {
            g.Hide()
            g.vis := false
        }
    }
}

; Цвета оверлеев не проходят ни тест "белое", ни тест "стрелка"
CreateOverlays() {
    DestroyOverlays()
    z := Cfg.zone
    h := Cfg.hole
    t := 3

    if (Cfg.frames) {
        zw := z.x2 - z.x1 + 1 + t + t
        zh := z.y2 - z.y1 + 1
        Ov.frame.Push(MakeOverlay(z.x1 - t, z.y1 - t, zw, t, "3060FF", 140))
        Ov.frame.Push(MakeOverlay(z.x1 - t, z.y2 + 1, zw, t, "3060FF", 140))
        Ov.frame.Push(MakeOverlay(z.x1 - t, z.y1, t, zh, "3060FF", 140))
        Ov.frame.Push(MakeOverlay(z.x2 + 1, z.y1, t, zh, "3060FF", 140))
        if (h.on) {
            hw := h.x2 - h.x1 + 1
            hh := h.y2 - h.y1 + 1
            Ov.hole.Push(MakeOverlay(h.x1, h.y1, hw, t, "9040FF", 140))
            Ov.hole.Push(MakeOverlay(h.x1, h.y2 - t + 1, hw, t, "9040FF", 140))
            Ov.hole.Push(MakeOverlay(h.x1, h.y1, t, hh, "9040FF", 140))
            Ov.hole.Push(MakeOverlay(h.x2 - t + 1, h.y1, t, hh, "9040FF", 140))
        }
    }

    if (Cfg.markers) {
        loop 4 {
            g := MakeOverlay(0, 0, 4, 2, "30FF60", 210)
            HideOv(g)
            Ov.box.Push(g)
        }
        Ov.tickX := MakeOverlay(0, 0, 2, 12, "FFFF30", 220)
        HideOv(Ov.tickX)
        Ov.tickY := MakeOverlay(0, 0, 12, 2, "FFFF30", 220)
        HideOv(Ov.tickY)
    }
}

DestroyOverlays() {
    for g in Ov.frame
        try g.Destroy()
    for g in Ov.hole
        try g.Destroy()
    for g in Ov.box
        try g.Destroy()
    Ov.frame := []
    Ov.hole := []
    Ov.box := []
    if (IsObject(Ov.tickX))
        try Ov.tickX.Destroy()
    Ov.tickX := 0
    if (IsObject(Ov.tickY))
        try Ov.tickY.Destroy()
    Ov.tickY := 0
}

ShowBox(b) {
    if (Ov.box.Length < 4)
        return
    t := 2
    x0 := b.x1 - t - 1
    y0 := b.y1 - t - 1
    w := (b.x2 - b.x1 + 1) + 2 * (t + 1)
    h := (b.y2 - b.y1 + 1) + 2 * (t + 1)
    PlaceOvRect(Ov.box[1], x0, y0, w, t)
    PlaceOvRect(Ov.box[2], x0, y0 + h - t, w, t)
    PlaceOvRect(Ov.box[3], x0, y0, t, h)
    PlaceOvRect(Ov.box[4], x0 + w - t, y0, t, h)
}

HideBox() {
    for g in Ov.box
        HideOv(g)
}

ShowArrowTicks(rx, ry) {
    PlaceOvRect(Ov.tickX, rx - 1, Cfg.zone.y2 + 6, 2, 12)
    PlaceOvRect(Ov.tickY, Cfg.zone.x2 + 6, ry - 1, 12, 2)
}

HideArrowTicks() {
    HideOv(Ov.tickX)
    HideOv(Ov.tickY)
}

HideMarkers() {
    HideBox()
    HideArrowTicks()
}

; ---------------------- Один проход: маски белого и красного ----------------------
BuildMasks(&mw, &mr, &gw, &gh) {
    g := Cap.g
    if (!IsObject(g))
        return false
    z := Cfg.zone
    pBits := g.pBits
    W := g.w
    H := g.h
    st := Cfg.blob.step
    gw := (W + st - 1) // st
    gh := (H + st - 1) // st
    mw := Buffer(gw * gh, 0)
    mr := Buffer(gw * gh, 0)

    wMin := Cfg.white.minBright
    wSat := Cfg.white.maxSat
    aMinR := Cfg.arrow.minR
    aDom := Cfg.arrow.domR
    aMaxGB := Cfg.arrow.maxGB

    hOn := Cfg.hole.on
    hx1 := Cfg.hole.x1 - z.x1
    hy1 := Cfg.hole.y1 - z.y1
    hx2 := Cfg.hole.x2 - z.x1
    hy2 := Cfg.hole.y2 - z.y1
    holeSkip := (hx2 // st) + 1

    gy := 0
    while (gy < gh) {
        py := gy * st
        rowOff := py * W * 4
        rowIdx := gy * gw
        holeRow := (hOn && py >= hy1 && py <= hy2)
        gx := 0
        while (gx < gw) {
            px := gx * st
            if (holeRow && px >= hx1 && px <= hx2) {
                gx := holeSkip
                continue
            }
            c := NumGet(pBits, rowOff + px * 4, "uint")
            bl := c & 0xFF
            gr := (c >> 8) & 0xFF
            rd := (c >> 16) & 0xFF
            if (bl >= wMin && gr >= wMin && rd >= wMin) {
                mn := bl
                mx := bl
                if (gr < mn)
                    mn := gr
                if (gr > mx)
                    mx := gr
                if (rd < mn)
                    mn := rd
                if (rd > mx)
                    mx := rd
                if (mx - mn <= wSat)
                    NumPut("uchar", 1, mw, rowIdx + gx)
            } else if (rd >= aMinR) {
                mxGB := (gr > bl) ? gr : bl
                if (mxGB <= aMaxGB && rd - mxGB >= aDom)
                    NumPut("uchar", 1, mr, rowIdx + gx)
            }
            gx++
        }
        gy++
    }
    return true
}

; Связные компоненты (8-связность). Маска расходуется.
LabelBlobs(mask, gw, gh) {
    blobs := []
    stack := []
    gy := 0
    while (gy < gh) {
        gx := 0
        while (gx < gw) {
            i := gy * gw + gx
            if (NumGet(mask, i, "uchar") = 1) {
                NumPut("uchar", 2, mask, i)
                stack.Push(i)
                cells := 0
                sx := 0
                sy := 0
                minx := gx
                maxx := gx
                miny := gy
                maxy := gy
                while (stack.Length > 0) {
                    k := stack.Pop()
                    ky := k // gw
                    kx := k - ky * gw
                    cells++
                    sx += kx
                    sy += ky
                    if (kx < minx)
                        minx := kx
                    if (kx > maxx)
                        maxx := kx
                    if (ky < miny)
                        miny := ky
                    if (ky > maxy)
                        maxy := ky
                    ny := ky - 1
                    while (ny <= ky + 1) {
                        if (ny >= 0 && ny < gh) {
                            nx := kx - 1
                            while (nx <= kx + 1) {
                                if (nx >= 0 && nx < gw) {
                                    ni := ny * gw + nx
                                    if (NumGet(mask, ni, "uchar") = 1) {
                                        NumPut("uchar", 2, mask, ni)
                                        stack.Push(ni)
                                    }
                                }
                                nx++
                            }
                        }
                        ny++
                    }
                }
                blobs.Push({ cells: cells, sx: sx, sy: sy,
                             minx: minx, maxx: maxx, miny: miny, maxy: maxy })
            }
            gx++
        }
        gy++
    }
    return blobs
}

MergeRaw(raw, gap) {
    changed := true
    while (changed) {
        changed := false
        i := 1
        while (i <= raw.Length) {
            j := i + 1
            while (j <= raw.Length) {
                a := raw[i]
                q := raw[j]
                near := (a.minx - gap <= q.maxx) && (q.minx - gap <= a.maxx) && (a.miny - gap <= q.maxy) && (q.miny - gap <= a.maxy)
                if (near) {
                    a.cells += q.cells
                    a.sx += q.sx
                    a.sy += q.sy
                    a.minx := Min(a.minx, q.minx)
                    a.maxx := Max(a.maxx, q.maxx)
                    a.miny := Min(a.miny, q.miny)
                    a.maxy := Max(a.maxy, q.maxy)
                    raw.RemoveAt(j)
                    changed := true
                } else {
                    j++
                }
            }
            i++
        }
    }
}

WhiteMetrics(raw, st) {
    z := Cfg.zone
    out := []
    for b in raw {
        cw := b.maxx - b.minx + 1
        ch := b.maxy - b.miny + 1
        bw := cw * st
        bh := ch * st
        area := b.cells * st * st
        fill := b.cells / Max(cw * ch, 1)
        lo := Min(bw, bh)
        hi := Max(bw, bh)
        out.Push({
            cx: z.x1 + Round(b.sx / b.cells * st + (st - 1) / 2),
            cy: z.y1 + Round(b.sy / b.cells * st + (st - 1) / 2),
            x1: Max(z.x1, z.x1 + b.minx * st),
            y1: Max(z.y1, z.y1 + b.miny * st),
            x2: Min(z.x2, z.x1 + b.maxx * st + st - 1),
            y2: Min(z.y2, z.y1 + b.maxy * st + st - 1),
            w: bw, h: bh, area: area, fill: fill, aspect: hi / Max(lo, 1)
        })
    }
    return out
}

PickWhite(list) {
    c := Cfg.blob
    best := 0
    bestScore := -1
    for b in list {
        if (b.area < c.minAreaPx)
            continue
        if (b.w < c.minSide || b.h < c.minSide)
            continue
        if (b.w > c.maxSide || b.h > c.maxSide)
            continue
        if (b.aspect > c.maxAspect)
            continue
        if (b.fill < c.minFill)
            continue
        score := b.area * b.fill / b.aspect
        if (S.tgt.ok && Abs(b.cx - S.tgt.cx) + Abs(b.cy - S.tgt.cy) <= c.trackDist)
            score *= 1.8
        if (score > bestScore) {
            bestScore := score
            best := b
        }
    }
    return best
}

PickRed(raw) {
    best := 0
    bestCells := Cfg.arrow.minCells - 1
    for b in raw {
        if (b.cells > bestCells) {
            bestCells := b.cells
            best := b
        }
    }
    return best
}

; Угловой центр и полуширина цели относительно оси
TargetAngles(t, cx, cy) {
    base := Ang(t.cx - cx, t.cy - cy)
    mn := 0
    mx := 0
    for x in [t.x1, t.x2] {
        for y in [t.y1, t.y2] {
            d := AngWrap(Ang(x - cx, y - cy) - base)
            if (d < mn)
                mn := d
            if (d > mx)
                mx := d
        }
    }
    return { a: base + (mn + mx) / 2, half: (mx - mn) / 2 }
}

; Угловая скорость, град/мс (МНК по последним точкам)
Omega() {
    n := S.hist.Length
    if (n < 2)
        return 0
    m := (n < 4) ? n : 4
    i0 := n - m + 1
    tBase := S.hist[i0].t
    sT := 0
    sA := 0
    sTT := 0
    sTA := 0
    i := i0
    while (i <= n) {
        h := S.hist[i]
        tt := h.t - tBase
        sT += tt
        sA += h.a
        sTT += tt * tt
        sTA += tt * h.a
        i++
    }
    d := m * sTT - sT * sT
    if (Abs(d) < 0.000001)
        return 0
    return (m * sTA - sT * sA) / d
}

; ---------------------- Ввод ----------------------
SendKey(down) {
    k := "{" Cfg.key (down ? " down}" : " up}")
    if (Cfg.keyMode = "event")
        SendEvent(k)
    else
        SendInput(k)
}

PressKey() {
    S.pressPending := false
    if (S.keyDown)
        return
    S.keyDown := true
    S.lastPress := QPC()
    SendKey(true)
    SetTimer ReleaseKey, -Abs(Cfg.hold)
}

ReleaseKey() {
    if (!S.keyDown)
        return
    SendKey(false)
    S.keyDown := false
}

DoPress(delayMs, why) {
    S.armed := false
    S.why := why
    S.hits++
    if (delayMs <= 1) {
        S.pressPending := false
        PressKey()
    } else {
        S.pressPending := true
        SetTimer PressKey, -Round(delayMs)
    }
}

Tip(text := "", ms := 1200) {
    ToolTip(text)
    SetTimer ClearTip, -Abs(ms)
}

ClearTip() {
    ToolTip()
}

; ---------------------- Логика ----------------------
CheckSkill() {
    if (S.busy)
        return
    S.busy := true
    try {
        Tick()
        if (Cfg.debug)
            ToolTip(S.dbg, Cfg.zone.x2 + 24, Cfg.zone.y1, 2)
    } catch Any as e {
        Tip("Ошибка: " e.Message, 2500)
    } finally {
        S.busy := false
    }
}

Tick() {
    if (Cfg.win != "" && !WinActive(Cfg.win)) {
        HideMarkers()
        return
    }
    if (!GrabZone()) {
        HideMarkers()
        S.dbg := "нет кадра (BitBlt). Проверь F8 / оконный режим"
        return
    }
    tCap := QPC()
    st := Cfg.blob.step
    z := Cfg.zone

    if (!BuildMasks(&mw, &mr, &gw, &gh))
        return

    ; ---- цель (белый квадрат) ----
    wRaw := LabelBlobs(mw, gw, gh)
    MergeRaw(wRaw, Ceil(Cfg.blob.mergeGap / st))
    wList := WhiteMetrics(wRaw, st)
    wBest := PickWhite(wList)

    if (IsObject(wBest)) {
        if (!S.tgt.ok || Abs(wBest.cx - S.tgt.cx) > Cfg.moveDist || Abs(wBest.cy - S.tgt.cy) > Cfg.moveDist) {
            S.armed := true
            S.hist := []
            if (tCap - S.lastPress > Cfg.resetAfter)
                S.hits := 0
        }
        S.tgt.ok := true
        S.tgt.cx := wBest.cx
        S.tgt.cy := wBest.cy
        S.tgt.x1 := wBest.x1
        S.tgt.y1 := wBest.y1
        S.tgt.x2 := wBest.x2
        S.tgt.y2 := wBest.y2
        S.tgt.t := tCap
        ShowBox(S.tgt)
    } else if (S.tgt.ok && tCap - S.tgt.t > Cfg.targetHold) {
        S.tgt.ok := false
        S.armed := true
        S.hist := []
        HideBox()
    }

    if (!S.tgt.ok) {
        HideArrowTicks()
        S.scanMs := QPC() - tCap
        if (Cfg.debug)
            S.dbg := "цели нет | белых кандидатов " wList.Length
        return
    }

    ; ---- стрелка ----
    rRaw := LabelBlobs(mr, gw, gh)
    rBest := PickRed(rRaw)
    if (!IsObject(rBest)) {
        HideArrowTicks()
        S.hist := []
        if (tCap - S.lastArrow > Cfg.rearmAfter)
            S.armed := true
        S.scanMs := QPC() - tCap
        if (Cfg.debug)
            S.dbg := "стрелки нет | красных кластеров " rRaw.Length
        return
    }
    S.lastArrow := tCap

    C := CenterPt()
    ax := z.x1 + (rBest.sx / rBest.cells) * st + (st - 1) / 2
    ay := z.y1 + (rBest.sy / rBest.cells) * st + (st - 1) / 2
    ShowArrowTicks(Round(ax), Round(ay))

    aNow := Ang(ax - C.x, ay - C.y)
    if (S.hist.Length = 0) {
        S.t0 := tCap
        S.aPrev := aNow
        S.aTot := 0
        S.hist.Push({ t: 0, a: 0 })
    } else {
        S.aTot += AngWrap(aNow - S.aPrev)
        S.aPrev := aNow
        S.hist.Push({ t: tCap - S.t0, a: S.aTot })
        while (S.hist.Length > 5)
            S.hist.RemoveAt(1)
    }
    om := Omega()

    tg := TargetAngles(S.tgt, C.x, C.y)
    off := AngWrap(aNow - tg.a)
    inside := (Abs(off) <= tg.half + Cfg.arrow.hitPadDeg)

    tStar := 99999
    past := 99999
    if (Abs(om) >= Cfg.predict.minOmega) {
        dir := (om > 0) ? 1 : -1
        tStar := AngFwd(aNow, tg.a, dir) / Abs(om)
        past := AngFwd(tg.a, aNow, dir) / Abs(om)
    }

    canHit := (S.armed && !S.pressPending && S.hits < Cfg.maxHits && tCap - S.lastPress > Cfg.cooldown)
    if (canHit) {
        if (Cfg.predict.on && tStar <= Cfg.predict.lookahead) {
            fire := tStar - Cfg.predict.latency - Cfg.predict.lead - (QPC() - tCap)
            if (fire <= Cfg.tickRate)
                DoPress(fire, "predict " Round(tStar) "мс")
        } else if (inside) {
            DoPress(0, "overlap")
        } else if (past <= Cfg.predict.lateGrace) {
            DoPress(0, "late " Round(past) "мс")
        }
    }

    S.scanMs := QPC() - tCap
    if (Cfg.debug)
        S.dbg := Format("w {:.0f} гр/с | до цели {} мс | смещ {:.1f} гр | полушир {:.1f} гр{}armed {} | hits {} | скан {:.1f} мс | кандидаты б{} к{} | {}",
            om * 1000, (tStar > 9000 ? "-" : Round(tStar)), off, tg.half, NL,
            (S.armed ? 1 : 0), S.hits, S.scanMs, wList.Length, rRaw.Length, S.why)
}

; ---------------------- Хоткеи ----------------------
F1:: {
    S.on := !S.on
    S.armed := true
    S.busy := false
    S.hits := 0
    S.hist := []
    S.tgt.ok := false
    S.pressPending := false
    if (S.on) {
        EnsureGrab()
        CreateOverlays()
        SetTimer CheckSkill, Cfg.tickRate
        Tip("SkillCheck: ON  (latency " Cfg.predict.latency " мс)")
    } else {
        SetTimer CheckSkill, 0
        SetTimer PressKey, 0
        ReleaseKey()
        DestroyOverlays()
        ToolTip(, , , 2)
        Cap.g := 0
        Tip("SkillCheck: OFF")
    }
}

F2:: {
    Cfg.markers := !Cfg.markers
    if (S.on)
        CreateOverlays()
    Tip("Маркеры: " (Cfg.markers ? "ON" : "OFF"))
}

F3:: {
    MouseGetPos(&px, &py)
    c := PixelGetColor(px, py)
    rd := (c >> 16) & 0xFF
    gr := (c >> 8) & 0xFF
    bl := c & 0xFF
    mn := Min(rd, gr, bl)
    mxAll := Max(rd, gr, bl)
    mxGB := Max(gr, bl)
    isW := (mn >= Cfg.white.minBright && mxAll - mn <= Cfg.white.maxSat)
    isA := (rd >= Cfg.arrow.minR && mxGB <= Cfg.arrow.maxGB && rd - mxGB >= Cfg.arrow.domR)
    hex := Format("0x{:06X}", c)
    A_Clipboard := hex
    Tip("Цвет: " hex "  R" rd " G" gr " B" bl NL
      . "мин.канал " mn ", насыщенность " (mxAll - mn) NL
      . "белое: " (isW ? "ДА" : "нет") "   |   стрелка: " (isA ? "ДА" : "нет") NL
      . "x" px " y" py, 4000)
}

F4:: {
    MouseGetPos(&mx, &my)
    z := Cfg.zone
    if (mx < z.x1 || mx > z.x2 || my < z.y1 || my > z.y2) {
        Tip("Курсор вне зоны сканирования", 2000)
        return
    }
    if (!GrabZone()) {
        Tip("Кадр не снялся, смотри F8", 2500)
        return
    }
    st := Cfg.blob.step
    if (!BuildMasks(&mw, &mr, &gw, &gh)) {
        Tip("Маски не построились", 2000)
        return
    }
    raw := LabelBlobs(mw, gw, gh)
    MergeRaw(raw, Ceil(Cfg.blob.mergeGap / st))
    list := WhiteMetrics(raw, st)
    if (list.Length = 0) {
        Tip("Белых кластеров нет." NL "Понизь white.minBright или подними white.maxSat", 4000)
        return
    }
    pick := 0
    bestD := 999999
    for b in list {
        d := Abs(b.cx - mx) + Abs(b.cy - my)
        if (d < bestD) {
            bestD := d
            pick := b
        }
    }
    C := CenterPt()
    rad := Sqrt((pick.cx - C.x) ** 2 + (pick.cy - C.y) ** 2)
    tg := TargetAngles(pick, C.x, C.y)
    txt := "Цель под курсором:" NL
         . Format("{}x{} px, площадь ~{}, fill {:.2f}, aspect {:.2f}", pick.w, pick.h, pick.area, pick.fill, pick.aspect) NL
         . Format("радиус от оси {:.0f} px, угловая полуширина {:.1f} гр", rad, tg.half) NL
         . "ось: " Round(C.x) "," Round(C.y) (Cfg.center.auto ? " (auto)" : " (задана F7)") NL
         . "Рекомендую: minAreaPx~" Round(pick.area * 0.45)
         . ", minSide~" Max(4, Round(Min(pick.w, pick.h) * 0.6))
         . ", maxSide~" Round(Max(pick.w, pick.h) * 1.8) NL
         . "Кластеров в кадре: " list.Length
    A_Clipboard := txt
    Tip(txt, 7000)
}

F5:: {
    Cfg.debug := !Cfg.debug
    if (!Cfg.debug)
        ToolTip(, , , 2)
    Tip("Debug: " (Cfg.debug ? "ON" : "OFF"))
}

; Задать зону мышью: F6 в одном углу, F6 в противоположном
F6:: {
    MouseGetPos(&mx, &my)
    if (S.zoneStep = 0) {
        S.tmpX := mx
        S.tmpY := my
        S.zoneStep := 1
        Tip("Угол 1: " mx "," my NL "Наведи на противоположный угол и нажми F6", 5000)
    } else {
        Cfg.zone.x1 := S.tmpX
        Cfg.zone.y1 := S.tmpY
        Cfg.zone.x2 := mx
        Cfg.zone.y2 := my
        NormRect(Cfg.zone)
        S.zoneStep := 0
        S.tgt.ok := false
        Cap.g := 0
        EnsureGrab()
        if (S.on)
            CreateOverlays()
        Tip("Зона: " Cfg.zone.x1 "," Cfg.zone.y1 " - " Cfg.zone.x2 "," Cfg.zone.y2, 3000)
    }
}

; Задать ось вращения стрелки (центр круга)
F7:: {
    MouseGetPos(&mx, &my)
    Cfg.center.auto := false
    Cfg.center.x := mx
    Cfg.center.y := my
    S.hist := []
    Tip("Ось стрелки: " mx "," my, 2500)
}

; Тест захвата экрана
F8:: {
    if (!GrabZone()) {
        Tip("BitBlt не сработал. Переключи игру в Windowed / Borderless", 5000)
        return
    }
    g := Cap.g
    pBits := g.pBits
    W := g.w
    H := g.h
    first := NumGet(pBits, 0, "uint")
    same := true
    mn := 999
    mx := -1
    y := 0
    while (y < H) {
        rowOff := y * W * 4
        x := 0
        while (x < W) {
            c := NumGet(pBits, rowOff + x * 4, "uint")
            if (c != first)
                same := false
            lum := ((c & 0xFF) + ((c >> 8) & 0xFF) + ((c >> 16) & 0xFF)) // 3
            if (lum < mn)
                mn := lum
            if (lum > mx)
                mx := lum
            x += 4
        }
        y += 4
    }
    Tip("Кадр " W "x" H NL "яркость " mn " ... " mx NL
      . (same ? "ВСЁ ОДНОГО ЦВЕТА -> экран не захватывается (exclusive fullscreen). Включи Windowed/Borderless."
              : "захват работает нормально"), 7000)
}

; Предсказание вкл/выкл
F9:: {
    Cfg.predict.on := !Cfg.predict.on
    Tip("Предсказание: " (Cfg.predict.on ? "ON" : "OFF (только по совмещению)"))
}

; Живая подстройка задержки
NumpadAdd:: {
    Cfg.predict.latency += 2
    Tip("latency = " Cfg.predict.latency " мс (жмёт раньше)", 1200)
}

NumpadSub:: {
    Cfg.predict.latency -= 2
    Tip("latency = " Cfg.predict.latency " мс (жмёт позже)", 1200)
}

Esc::ExitApp