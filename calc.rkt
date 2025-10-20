#lang racket

(define interactive? (not (member "-b" (current-command-line-arguments))))

;; Helper: check if a symbol is a $n reference and return its index
(define (get-history-index sym)
  (if (and (symbol? sym)
           (regexp-match #rx"^\\$[0-9]+$" (symbol->string sym)))
      (string->number (substring (symbol->string sym) 1))
      #f))

(define (process-expression history)
  (display "Enter an expression: ")
  (define user-input (read))
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (display "Error: Invalid Expression\n"))])
    ;; evaluate the expression
    (define result (eval user-input))

    ;; add result to history (front of list)
    (define new-history (cons result history))

    ;; calculate history id (number of results so far + 1)
    (define history-id (+ 1 (length history))) ;; first result = 1

    (display history-id)
    (display ": ")
    (display result)
    (newline)

    ;; return updated history
    new-history))

(define (start-program history)
  (if interactive?
      (let ([new-history (process-expression history)])  ; use let instead of define
        (start-program new-history))                    ; pass updated history
      (begin
        (display "Batch mode: single expression evaluation\n")
        (process-expression history))))


(start-program '())
