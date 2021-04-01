(set-bounds! [-10 -10 -15] [10 10 40])
(set-quality! 8)
(set-resolution! 8)


(define PI 3.1415926535)

(define leg
  (let ((radius 4)
        (height 23)
        (reduction 1))
    (rotate-y
      (intersection
        (box [(- reduction radius) (- radius) (- radius)]
             [(- radius reduction) radius (+ height radius)])
        (blend
          (blend
            (sphere    radius [0 0 0])
            (cylinder  (- radius (/ reduction 2)) height)
            0.5)
          (sphere    radius [0 0 height])
          0.5))
      (/ PI 20))))

(define pressure-point (rotate-y
                         (cylinder 4 9 [0 0 -4])
                         (/ PI 2)))

(define drill
  (rotate-y (circle 2)
            (/ PI 2)))

(difference 
  (union
    leg pressure-point)
  drill)


