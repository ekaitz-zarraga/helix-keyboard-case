
(set-bounds! [-1 -1 -1] [150 150 50])
(set-quality! 8)
(set-resolution! 8)


; Z
(define pcb-z 2)
(define border-height   (+ pcb-z 2)) ; Includes PCB thickness
(define base-thickness  2)
(define support-height  6)
(define outer-thickness (+ border-height base-thickness support-height))


; X-Y
(define border-x  7)
(define border-y  3)
(define tolerance 1) ; In each edge of the PCB

; X
(define pcb-x 132)
(define inner-width  (+ pcb-x (* 2 tolerance)))
(define outer-width  (+ pcb-x (* 2 tolerance) (* 2 border-x)))
; Y
(define pcb-y 94)
(define inner-height (+ pcb-y (* 2 tolerance)))
(define outer-height (+ pcb-y (* 2 tolerance) (* 2 border-y)))


(define m3-drill-size 2) ; Compatible with metal inserts like
                               ; https://tienda.bricogeek.com/tornillos-y-tuercas/669-inserto-para-plastico-m3x4mm-20-unidades.html

(define (radius->apothem r)
  (sqrt (- (expt r 2) (expt (/ r 2) 2))))
(define (apothem->radius ap)
  (sqrt (* (expt ap 2) 4/3)))


(define (screw-support height
                       radius
                       drill-size)
  (difference
    (cylinder radius height)
    (cylinder drill-size height)))


(define (box-rounded-sides h w d r)
  "Positioned in 0 0 0"
  (extrude-z
      (rounded-rectangle #[0 0] #[w d] r) ;draw base
      0
      h))




(define base-support (screw-support support-height 3.5 m3-drill-size))
(define main-supports
  (union
    (move (array-xy base-support
                  3 2 #[38 38])
        ; Move to position and place on top of the base
          #[(+ 18.5 border-x tolerance)
            (+ 18.5 border-y tolerance)
            base-thickness])
     (move (array-x base-support 3 (* 2 19))
                #[(+ 18.5 border-x tolerance)
                  (+ 75.5 border-y tolerance)
                  base-thickness])
     (move base-support
           #[(+ 18.5 border-x tolerance (* 19 5))
             (+ 75.5 border-y tolerance)
             base-thickness])))

(define helix-case
  (difference
    (box-rounded-sides outer-thickness
                       outer-width
                       outer-height
                       (/ border-x 3))
    (move (box-rounded-sides
                       (+ border-height support-height)
                       inner-width
                       inner-height
                       1)
           #[border-x border-y base-thickness])))

(define PI 3.1415926535)

(define side-drills
  (let ((radius m3-drill-size))
  (move (rotate-y
    (union
    (cylinder radius border-x #[0 (+ border-y tolerance 17)      0])
    (cylinder radius border-x #[0 (- outer-height border-y 17) 0])
    (cylinder radius border-x #[0 (+ border-y tolerance 17)    (- outer-width border-x)])
    (cylinder radius border-x #[0 (- outer-height border-y 17) (- outer-width border-x)]))
        (/ (- PI) 2))
    #[0 0 (+ radius base-thickness)]))) ; For positioning legs

(define usb-hole
  (let ((size 20))
    (move
       (box #[0 0 0] #[size (+ border-y 3) (+ pcb-z border-height)])
          #[(- outer-width size border-x) 0 (+ support-height)])))

(define jack-hole-shape
  (let* ((radius 6.5)
         (round-hole (rotate-y (cylinder radius border-x) (/ pi 2)))
         (width 4))
    (move
      (union
         (box #[(- border-x) 0 (- radius)] #[0 width radius])
         (move round-hole #[0 width])
         round-hole)
         #[0 0 0])))

(define jack-hole
  (let ((size 12.5))
    (move
      jack-hole-shape
      #[outer-width (+ border-y tolerance 40) outer-thickness])))

(define cover-drills
  (union
    (circle m3-drill-size #[(- outer-width (/ border-x 2)) (/ border-x 2)])
    (circle m3-drill-size #[(- outer-width (/ border-x 2)) (+ border-y tolerance 55)])))

(difference
  (union
        helix-case
        main-supports 0.5)
        usb-hole
        jack-hole
        side-drills
        cover-drills)
