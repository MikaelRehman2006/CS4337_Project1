#lang racket

(define interactive? (not (member "-b" (current-command-line-arguments))))

(define (process-expression)
    (display "Enter an expression: ")
    (define user-input(read))
    (display "You entered: ")
    (display user-input)
    (newline))
