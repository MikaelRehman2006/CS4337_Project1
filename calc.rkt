#lang racket

(define interactive? (not (member "-b" (current-command-line-arguments))))

(define (process-expression)
    (display "Enter an expression: ")
    (define user-input(read))
    (display "You entered: ")
    (display user-input)
    (newline))

(define (start-program)
    (if interactive?
        (begin
          (process-expression)
          (start-program))
        (begin
            (display "Batch mode: single expression evaluation\n")
            (process-expression))))

(start-program)
