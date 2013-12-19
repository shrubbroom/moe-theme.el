;; moe-theme-switcher.el
;; Author: kuanyui (azazabc123@gmail.com)
;; Date: 2013/05/11 11:39
;;
;; This file is not a part of GNU Emacs,
;; but this file is released under GPL v3.

(require 'moe-dark-theme)
(require 'moe-light-theme)

(defvar moe-theme-switch-by-sunrise-and-sunset t
"Automatically switch between dark and light moe-theme.

If this value is nil, moe-theme will switch at fixed time (06:00 and 18:00).

If this value is t and both calendar-latitude and calendar-longitude are set properly, the switching will be triggered at the sunrise and sunset time of the local calendar.

Take Keelung, Taiwan(25N,121E) for example, you can set like this:

	(setq calendar-latitude +25)
	(setq calendar-longitude +121)"
)

(defun switch-at-fixed-time ()
  (let ((now (string-to-int (format-time-string "%H"))))
    (if (and (>= now 06) (<= now 18))
        (load-theme 'moe-light t) (load-theme 'moe-dark t))
    nil))

(defun float-to-time-list (time)
  "Converts time represented as a float to a list
Example:
> (float-to-time-list 4.5)
=> (4 30)
> (float-to-time-list 8.633333332836628)
=> (8 37)"
  (let* ((hours (truncate time))
         (minutes (truncate (* (- time hours) 60))))
    (list hours minutes)))

;; Excute every minute.
(defun switch-by-locale ()
  (let ((sunrise-sunset a b c)
        (length-of-day a b)
        (sunrise a)
        (sunset a))
    (setq sunrise-sunset (solar-sunrise-sunset (calendar-current-date)))
    ; length of day should never be nil
    (setq length-of-day (mapcar
                         (lambda (x) (string-to-number x))
                         (split-string (car (cddr sunrise-sunset ":")))))

    (if (equal length-of-day '(0 0)) ; Polar night
        (load-theme 'moe-dark t)
      (if (equal length-of-day '(24 0)) ; Midnight sun
          (load-theme 'moe-light t)
        (let ((now (list (string-to-number (format-time-string "%H"))
                         (string-to-number (format-time-string "%M"))))
              (sunrise (float-to-time-list (caar sunrise-sunset)))
              (sunset (float-to-time-list (car (cadr sunrise-sunset)))))
          (if (and
               (or (> (car now) (car sunrise))
                   (and (= (car now) (car sunrise))
                        (>= (cdr now) (cdr sunrise))))
               (or (< (car now) (car sunset))
                   (and (= (car now) (car sunset))
                        (< (cdr now) (cdr sunset)))))
              (load-theme 'moe-light t)
            (load-theme 'moe-dark t)))))))

(defun moe-theme-auto-switch ()
  (interactive)
  (if (and moe-theme-switch-by-sunrise-and-sunset
           (boundp 'calendar-longitude)
           (boundp 'calendar-latitude))
      (switch-by-locale)
    (switch-at-fixed-time)))

(moe-theme-auto-switch)

(run-with-timer 0 (* 1 60) 'moe-theme-auto-switch)

(provide 'moe-theme-switcher)



