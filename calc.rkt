#lang racket

(define interactive? (not (member "-b" (current-command-line-arguments))))

(define (process-expression history)
    (display "Enter an expression: ")
    (define user-input (read))
    (with-handlers ([exn:fail? 
                     (lambda (e) 
                       (display "Error: Invalid Expression\n"))])
        ;; evlauate the expression
        (define result (eval user-input))

        ;; add result to history (front of list)
        (define new-history (cons result history))

        ;; calculate history id (number of results in new-history)
        (define history-id (+ 1 (length history))) ;; first result = 1

        (display history-id)
        (display ": ")
        (display result)
        (newline)

        ;; return updated history
        new-history))


(define (start-program history)
    (if interactive?
        (begin
          (process-expression history)
          (start-program history))
        (begin
            (display "Batch mode: single expression evaluation\n")
            (process-expression history))))

(start-program `())
