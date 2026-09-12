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

; ==================== НАСТРОЙКИ ====================
Cfg := {
    ; Окно игры. "" = работать всегда. Пример: "ahk_exe RobloxPlayerBeta.exe"
    win: "",

    ; Зона сканирования (координаты экрана)
    zone: { x1: 866, y1: 501, x2: 1042, y2: 658 },

    ; Запретная зона внутри круга
    hole: { on: true, x1: 913, y1: 541, x2: 1001, y2: 590 },

    ; Ось вращения стрелки. auto = центр hole (или зоны), иначе auto: false + свои x/y.
    center: { auto: true, x: 0, y: 0 },

    ; Что считается белым: яркое и несатурированное
    white: { minBright: 200, maxSat: 30 },

    ; Белая зона skill-check живёт на кольце вокруг центра.
    ; Это главный фильтр против белых волос/скинов/объектов на фоне.
    ; maskMinR/maskMaxR — где вообще разрешено собирать белые пиксели.
    ; centerMinR/centerMaxR — где должен лежать ЦЕНТР готового кандидата.
    targetRing: {
        on:            true,
        maskMinR:      50,
        maskMaxR:      90,
        centerMinR:    56,
        centerMaxR:    82,
        minRadialSpan: 7,
        maxRadialSpan: 28,
        minAngleSpan:  5.0,
        maxAngleSpan:  28.0,
        radiusBonus:   0.65
    },

    ; Стрелка: красный доминирует над G и B.
    ; Красные пиксели вне кольца стрелки отбрасываем, чтобы не ловить фон/генератор.
    arrow: {
        minR: 110, domR: 45, maxGB: 150, minCells: 3, hitPadDeg: 1.5,
        maskMinRadius: 32, maskMaxRadius: 108,
        centerMinRadius: 38, centerMaxRadius: 100,
        minRadialRatio: 1.6
    },

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

    tickRate:   3,     ; период проверки, мс — быстрее для резких skill-check'ов
    cooldown:   25,    ; защита от двойного нажатия по ОДНОЙ цели; новая цель перевзводит отдельно
    moveDist:   25,    ; старый запасной критерий смены цели, px

    ; ЦЕПОЧКА skill-check'ов: стрелка может не останавливаться, а белая зона прыгать дальше.
    ; После удара запоминаем именно ту цель, по которой нажали. Как только появляется
    ; цель под заметно другим углом — сразу разрешаем следующий удар, НЕ сбрасывая
    ; историю скорости стрелки.
    chain: {
        on: true,
        rearmAngleDeg: 5.0, ; новая белая зона, если её центр ушёл >= этого угла
        rearmDistPx:   12,  ; доп. защита: заметный сдвиг по экрану
        minDistAngle:  2.5  ; dist учитываем только если есть хотя бы такой угловой сдвиг
    },

    maxHits:    20,    ; предохранитель от бесконечного спама
    resetAfter: 260,   ; мс без цели до сброса счётчика цепочки
    rearmAfter: 200,   ; мс без стрелки до повторного взвода
    targetHold: 220,   ; мс помнить цель, если детект мигнул
    hold:       18,    ; короткое удержание — позволяет быстро нажать второй раз
    key:        "Space",
    keyMode:    "input",  ; "input" | "event" (если игра игнорит SendInput)
    dpiAware:   false,    ; true только если масштаб экрана 100% и координаты сбиты

    hitboxes: true,   ; F2: рисовать все хитбоксы (зона, дыра, цель, кандидаты, стрелка)
    maxBoxes: 8,      ; сколько отвергнутых кандидатов подсвечивать одновременно

    ; Прятать рамки от захвата экрана: тебе видно, в записи/стриме/скриншоте — нет.
    ; Требует Windows 10 2004 (сборка 19041) или новее. false = рамки видны всем.
    hideFromCapture: true
}
; ===================================================

if (Cfg.dpiAware)
    try DllCall("SetThreadDpiAwarenessContext", "ptr", -3)

S := { on: false, armed: true, busy: false, keyDown: false, pressPending: false,
       hits: 0, lastPress: 0,
       tgt: { ok: false, cx: 0, cy: 0, x1: 0, y1: 0, x2: 0, y2: 0, t: 0 },
       hitTgt: { ok: false, cx: 0, cy: 0, a: 0 },
       hist: [], aPrev: 0, aTot: 0, t0: 0, lastArrow: 0 }

Ov  := { frame: [], hole: [], tgt: [], arrow: [], cand: [], tickX: 0, tickY: 0 }
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
    ; WDA_EXCLUDEFROMCAPTURE (0x11): окно видно глазами, но вырезано из любого захвата экрана
    if (Cfg.hideFromCapture)
        try DllCall("SetWindowDisplayAffinity", "ptr", g.Hwnd, "uint", 0x11)
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

; Важно: все цвета оверлеев не проходят ни тест "белое", ни тест "стрелка",
; иначе скрипт ловил бы свои же рамки.
MakeBoxGroup(color, alpha) {
    grp := []
    loop 4 {
        g := MakeOverlay(0, 0, 4, 2, color, alpha)
        HideOv(g)
        grp.Push(g)
    }
    return grp
}

ShowBoxGroup(grp, x1, y1, x2, y2, t := 2) {
    if (grp.Length < 4)
        return
    x0 := x1 - t - 1
    y0 := y1 - t - 1
    w := (x2 - x1 + 1) + 2 * (t + 1)
    h := (y2 - y1 + 1) + 2 * (t + 1)
    PlaceOvRect(grp[1], x0, y0, w, t)
    PlaceOvRect(grp[2], x0, y0 + h - t, w, t)
    PlaceOvRect(grp[3], x0, y0, t, h)
    PlaceOvRect(grp[4], x0 + w - t, y0, t, h)
}

HideBoxGroup(grp) {
    for g in grp
        HideOv(g)
}

CreateOverlays() {
    DestroyOverlays()
    if (!Cfg.hitboxes)
        return
    z := Cfg.zone
    h := Cfg.hole
    t := 3

    ; синий — зона сканирования
    zw := z.x2 - z.x1 + 1 + t + t
    zh := z.y2 - z.y1 + 1
    Ov.frame.Push(MakeOverlay(z.x1 - t, z.y1 - t, zw, t, "3060FF", 140))
    Ov.frame.Push(MakeOverlay(z.x1 - t, z.y2 + 1, zw, t, "3060FF", 140))
    Ov.frame.Push(MakeOverlay(z.x1 - t, z.y1, t, zh, "3060FF", 140))
    Ov.frame.Push(MakeOverlay(z.x2 + 1, z.y1, t, zh, "3060FF", 140))

    ; фиолетовый — запретная дыра
    if (h.on) {
        hw := h.x2 - h.x1 + 1
        hh := h.y2 - h.y1 + 1
        Ov.hole.Push(MakeOverlay(h.x1, h.y1, hw, t, "9040FF", 140))
        Ov.hole.Push(MakeOverlay(h.x1, h.y2 - t + 1, hw, t, "9040FF", 140))
        Ov.hole.Push(MakeOverlay(h.x1, h.y1, t, hh, "9040FF", 140))
        Ov.hole.Push(MakeOverlay(h.x2 - t + 1, h.y1, t, hh, "9040FF", 140))
    }

    Ov.tgt := MakeBoxGroup("30FF60", 220)      ; зелёный — выбранная цель
    Ov.arrow := MakeBoxGroup("FFCC30", 220)    ; жёлтый — кластер стрелки
    Ov.cand := []
    loop Cfg.maxBoxes
        Ov.cand.Push(MakeBoxGroup("30D0FF", 170))   ; голубой — отвергнутые кандидаты

    Ov.tickX := MakeOverlay(0, 0, 2, 12, "FFCC30", 220)
    HideOv(Ov.tickX)
    Ov.tickY := MakeOverlay(0, 0, 12, 2, "FFCC30", 220)
    HideOv(Ov.tickY)
}

DestroyOverlays() {
    for g in Ov.frame
        try g.Destroy()
    for g in Ov.hole
        try g.Destroy()
    for g in Ov.tgt
        try g.Destroy()
    for g in Ov.arrow
        try g.Destroy()
    for grp in Ov.cand {
        for g in grp
            try g.Destroy()
    }
    Ov.frame := []
    Ov.hole := []
    Ov.tgt := []
    Ov.arrow := []
    Ov.cand := []
    if (IsObject(Ov.tickX))
        try Ov.tickX.Destroy()
    Ov.tickX := 0
    if (IsObject(Ov.tickY))
        try Ov.tickY.Destroy()
    Ov.tickY := 0
}

; Зелёная рамка — цель, голубые — все остальные белые кластеры в кадре
DrawWhiteBoxes(list, best) {
    if (S.tgt.ok)
        ShowBoxGroup(Ov.tgt, S.tgt.x1, S.tgt.y1, S.tgt.x2, S.tgt.y2)
    else
        HideBoxGroup(Ov.tgt)

    n := 0
    for b in list {
        if (n >= Ov.cand.Length)
            break
        if (IsObject(best) && b.cx = best.cx && b.cy = best.cy)
            continue
        n++
        ShowBoxGroup(Ov.cand[n], b.x1, b.y1, b.x2, b.y2, 1)
    }
    i := n + 1
    while (i <= Ov.cand.Length) {
        HideBoxGroup(Ov.cand[i])
        i++
    }
}

ShowArrowTicks(rx, ry) {
    PlaceOvRect(Ov.tickX, rx - 1, Cfg.zone.y2 + 6, 2, 12)
    PlaceOvRect(Ov.tickY, Cfg.zone.x2 + 6, ry - 1, 12, 2)
}

HideArrowTicks() {
    HideOv(Ov.tickX)
    HideOv(Ov.tickY)
}

HideArrowBox() {
    HideBoxGroup(Ov.arrow)
    HideArrowTicks()
}

HideMarkers() {
    HideBoxGroup(Ov.tgt)
    for grp in Ov.cand
        HideBoxGroup(grp)
    HideArrowBox()
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

    ; Геометрические фильтры считаем через квадрат радиуса — без Sqrt на каждом пикселе.
    ctr := CenterPt()
    ring := Cfg.targetRing
    ringOn := ring.on
    wR2Min := ring.maskMinR * ring.maskMinR
    wR2Max := ring.maskMaxR * ring.maskMaxR
    aR2Min := Cfg.arrow.maskMinRadius * Cfg.arrow.maskMinRadius
    aR2Max := Cfg.arrow.maskMaxRadius * Cfg.arrow.maskMaxRadius

    hOn := Cfg.hole.on
    hx1 := Cfg.hole.x1 - z.x1
    hy1 := Cfg.hole.y1 - z.y1
    hx2 := Cfg.hole.x2 - z.x1
    hy2 := Cfg.hole.y2 - z.y1
    holeSkip := (hx2 // st) + 1

    gy := 0
    while (gy < gh) {
        py := gy * st
        sy := z.y1 + py
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

            sx := z.x1 + px
            dx := sx - ctr.x
            dy := sy - ctr.y
            r2 := dx * dx + dy * dy

            whiteAllowed := (!ringOn || (r2 >= wR2Min && r2 <= wR2Max))
            arrowAllowed := (r2 >= aR2Min && r2 <= aR2Max)
            if (!whiteAllowed && !arrowAllowed) {
                gx++
                continue
            }

            c := NumGet(pBits, rowOff + px * 4, "uint")
            bl := c & 0xFF
            gr := (c >> 8) & 0xFF
            rd := (c >> 16) & 0xFF

            if (whiteAllowed && bl >= wMin && gr >= wMin && rd >= wMin) {
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
            }

            if (arrowAllowed && rd >= aMinR) {
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
                sxx := 0
                syy := 0
                sxy := 0
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
                    sxx += kx * kx
                    syy += ky * ky
                    sxy += kx * ky
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
                             sxx: sxx, syy: syy, sxy: sxy,
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
                    a.sxx += q.sxx
                    a.syy += q.syy
                    a.sxy += q.sxy
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
    C := CenterPt()
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

        bx1 := Max(z.x1, z.x1 + b.minx * st)
        by1 := Max(z.y1, z.y1 + b.miny * st)
        bx2 := Min(z.x2, z.x1 + b.maxx * st + st - 1)
        by2 := Min(z.y2, z.y1 + b.maxy * st + st - 1)
        bcx := z.x1 + Round(b.sx / b.cells * st + (st - 1) / 2)
        bcy := z.y1 + Round(b.sy / b.cells * st + (st - 1) / 2)

        ; Полярная геометрия кандидата относительно центра skill-check.
        ; Настоящая белая зона компактна и лежит касательно к окружности.
        baseA := Ang(bcx - C.x, bcy - C.y)
        centerR := Sqrt((bcx - C.x) * (bcx - C.x) + (bcy - C.y) * (bcy - C.y))
        rLo := 1000000.0
        rHi := 0.0
        aLo := 0.0
        aHi := 0.0
        for xx in [bx1, bx2] {
            for yy in [by1, by2] {
                dx := xx - C.x
                dy := yy - C.y
                rr := Sqrt(dx * dx + dy * dy)
                da := AngWrap(Ang(dx, dy) - baseA)
                if (rr < rLo)
                    rLo := rr
                if (rr > rHi)
                    rHi := rr
                if (da < aLo)
                    aLo := da
                if (da > aHi)
                    aHi := da
            }
        }

        out.Push({
            cx: bcx, cy: bcy,
            x1: bx1, y1: by1, x2: bx2, y2: by2,
            w: bw, h: bh, area: area, fill: fill, aspect: hi / Max(lo, 1),
            radius: centerR, radialSpan: rHi - rLo, angleSpan: aHi - aLo
        })
    }
    return out
}

PickWhite(list) {
    c := Cfg.blob
    ring := Cfg.targetRing
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

        ; Главная защита от белого скина: кандидат обязан иметь геометрию
        ; маленькой зоны на окружности, а не просто быть белым пятном.
        if (ring.on) {
            if (b.radius < ring.centerMinR || b.radius > ring.centerMaxR)
                continue
            if (b.radialSpan < ring.minRadialSpan || b.radialSpan > ring.maxRadialSpan)
                continue
            if (b.angleSpan < ring.minAngleSpan || b.angleSpan > ring.maxAngleSpan)
                continue
        }

        score := b.area * b.fill / b.aspect

        ; Бонус объекту ближе к середине ожидаемого кольца.
        if (ring.on) {
            rMid := (ring.centerMinR + ring.centerMaxR) / 2
            rHalf := Max((ring.centerMaxR - ring.centerMinR) / 2, 1)
            fit := 1 - Abs(b.radius - rMid) / rHalf
            if (fit > 0)
                score *= 1 + fit * ring.radiusBonus
        }

        ; После удара не цепляемся за старую белую зону: если рядом уже появилась
        ; новая зона, даём ей приоритет. Это важно, когда старая ещё видна 1-2 кадра.
        if (!S.armed && S.hitTgt.ok && IsNewTargetAfterHit(b))
            score *= 2.2
        else if (S.tgt.ok && Abs(b.cx - S.tgt.cx) + Abs(b.cy - S.tgt.cy) <= c.trackDist)
            score *= 1.8
        if (score > bestScore) {
            bestScore := score
            best := b
        }
    }
    return best
}

PickRed(raw) {
    z := Cfg.zone
    C := CenterPt()
    st := Cfg.blob.step
    a := Cfg.arrow
    best := 0
    bestCells := a.minCells - 1

    for b in raw {
        if (b.cells < a.minCells)
            continue

        mx := b.sx / b.cells
        my := b.sy / b.cells
        ax := z.x1 + mx * st + (st - 1) / 2
        ay := z.y1 + my * st + (st - 1) / 2
        dx := ax - C.x
        dy := ay - C.y
        rr := Sqrt(dx * dx + dy * dy)
        if (rr < a.centerMinRadius || rr > a.centerMaxRadius)
            continue

        ; Красная стрелка вытянута ПО РАДИУСУ от центра.
        ; Считаем дисперсию кластера вдоль радиуса и поперёк него.
        ; Это отбрасывает красные куски генератора/фона даже если цвет совпал.
        vx := b.sxx / b.cells - mx * mx
        vy := b.syy / b.cells - my * my
        cov := b.sxy / b.cells - mx * my
        ux := dx / rr
        uy := dy / rr
        vRad := ux * ux * vx + 2 * ux * uy * cov + uy * uy * vy
        vTan := uy * uy * vx - 2 * ux * uy * cov + ux * ux * vy
        radialRatio := (vRad + 0.05) / (vTan + 0.05)
        if (radialRatio < a.minRadialRatio)
            continue

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

; ---------------------- Цепочка целей ----------------------
RememberHitTarget() {
    if (!S.tgt.ok) {
        S.hitTgt.ok := false
        return
    }
    C := CenterPt()
    S.hitTgt.ok := true
    S.hitTgt.cx := S.tgt.cx
    S.hitTgt.cy := S.tgt.cy
    S.hitTgt.a := Ang(S.tgt.cx - C.x, S.tgt.cy - C.y)
}

; true = текущая белая зона уже не та, по которой был последний удар.
; Сравниваем в первую очередь угол на кольце: это устойчивее, чем просто X/Y.
IsNewTargetAfterHit(t) {
    if (!Cfg.chain.on || !S.hitTgt.ok)
        return false

    C := CenterPt()
    a := Ang(t.cx - C.x, t.cy - C.y)
    da := Abs(AngWrap(a - S.hitTgt.a))
    dx := t.cx - S.hitTgt.cx
    dy := t.cy - S.hitTgt.cy
    dist := Sqrt(dx * dx + dy * dy)

    if (da >= Cfg.chain.rearmAngleDeg)
        return true
    return (da >= Cfg.chain.minDistAngle && dist >= Cfg.chain.rearmDistPx)
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

DoPress(delayMs) {
    ; Блокируем повтор по этой же белой зоне, но запоминаем её, чтобы
    ; новая зона могла мгновенно перевзвести скрипт даже при непрерывной стрелке.
    RememberHitTarget()
    S.armed := false
    S.hits++
    if (delayMs <= 1) {
        S.pressPending := false
        PressKey()
    } else {
        S.pressPending := true
        SetTimer PressKey, -Round(delayMs)
    }
}

; ---------------------- Логика ----------------------
CheckSkill() {
    if (S.busy)
        return
    S.busy := true
    try {
        Tick()
    } catch Any {
        ; молча, без всплывающих подсказок
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
        return
    }
    tCap := QPC()
    st := Cfg.blob.step
    z := Cfg.zone

    if (!BuildMasks(&mw, &mr, &gw, &gh))
        return

    ; ---- цель (белая зона на кольце, поиск по всем 360 градусам) ----
    wRaw := LabelBlobs(mw, gw, gh)
    MergeRaw(wRaw, Ceil(Cfg.blob.mergeGap / st))
    wList := WhiteMetrics(wRaw, st)
    wBest := PickWhite(wList)

    if (IsObject(wBest)) {
        ; Главное для быстрых цепочек: после прошлого нажатия новая белая зона
        ; перевзводит следующий удар сама. Историю стрелки НЕ очищаем — она ведь
        ; может продолжать вращение без остановки.
        if (!S.armed && !S.pressPending && IsNewTargetAfterHit(wBest))
            S.armed := true

        ; Первый найденный target / обычная смена цели до нажатия.
        if (!S.tgt.ok) {
            S.armed := true
            if (tCap - S.lastPress > Cfg.resetAfter)
                S.hits := 0
        } else if (S.armed && (Abs(wBest.cx - S.tgt.cx) > Cfg.moveDist || Abs(wBest.cy - S.tgt.cy) > Cfg.moveDist)) {
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
    } else if (S.tgt.ok && tCap - S.tgt.t > Cfg.targetHold) {
        S.tgt.ok := false
        S.armed := true
        S.hitTgt.ok := false
        S.hist := []
    }

    if (Cfg.hitboxes)
        DrawWhiteBoxes(wList, wBest)

    if (!S.tgt.ok) {
        HideArrowBox()
        return
    }

    ; ---- стрелка ----
    rRaw := LabelBlobs(mr, gw, gh)
    rBest := PickRed(rRaw)
    if (!IsObject(rBest)) {
        HideArrowBox()
        S.hist := []
        if (tCap - S.lastArrow > Cfg.rearmAfter)
            S.armed := true
        return
    }
    S.lastArrow := tCap

    C := CenterPt()
    ax := z.x1 + (rBest.sx / rBest.cells) * st + (st - 1) / 2
    ay := z.y1 + (rBest.sy / rBest.cells) * st + (st - 1) / 2
    if (Cfg.hitboxes) {
        ShowArrowTicks(Round(ax), Round(ay))
        ShowBoxGroup(Ov.arrow,
            Max(z.x1, z.x1 + rBest.minx * st),
            Max(z.y1, z.y1 + rBest.miny * st),
            Min(z.x2, z.x1 + rBest.maxx * st + st - 1),
            Min(z.y2, z.y1 + rBest.maxy * st + st - 1))
    }

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
                DoPress(fire)
        } else if (inside) {
            DoPress(0)
        } else if (past <= Cfg.predict.lateGrace) {
            DoPress(0)
        }
    }
}

; ---------------------- Хоткеи ----------------------
F1:: {
    S.on := !S.on
    S.armed := true
    S.busy := false
    S.hits := 0
    S.hist := []
    S.tgt.ok := false
    S.hitTgt.ok := false
    S.pressPending := false
    if (S.on) {
        EnsureGrab()
        CreateOverlays()
        SetTimer CheckSkill, Cfg.tickRate
    } else {
        SetTimer CheckSkill, 0
        SetTimer PressKey, 0
        ReleaseKey()
        DestroyOverlays()
        Cap.g := 0
    }
}

; F2 — все хитбоксы вкл/выкл (без уведомлений)
F2:: {
    Cfg.hitboxes := !Cfg.hitboxes
    if (S.on) {
        if (Cfg.hitboxes)
            CreateOverlays()
        else
            DestroyOverlays()
    }
}

; F3 — предсказание (стрельба на опережение) вкл/выкл (без уведомлений)
F3:: {
    Cfg.predict.on := !Cfg.predict.on
    S.hist := []
}

; Esc БОЛЬШЕ НЕ ЗАКРЫВАЕТ скрипт (в игре Esc — это меню).
; Выход: правый клик по иконке AHK в трее -> Exit.